import json
import os
import time
import hmac
import hashlib
import secrets
import threading
import base64
import random
import requests
from urllib.parse import quote, urlencode
from datetime import datetime, timezone
from flask import Flask, request, jsonify, send_from_directory, render_template, redirect, url_for, make_response

DISCORD_WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL")
DISCORD_AVATAR_URL = "https://i.imgur.com/xY7M2iE.jpeg"

EVENT_COLORS = {
    "Created": 0x34D399,
    "Created (Admin)": 0xFA5050,
    "Extended": 0x60A5FA,
    "Extended (User)": 0x60A5FA,
    "Reduced": 0xFBBF24,
    "Deleted": 0xEF4444,
    "Expired": 0x9CA3AF,
    "First Use": 0xFA5050,
    "HWID Mismatch": 0xF97316,
    "HWID Reset": 0xA855F7,
    "Spoof Attempt": 0xDC2626,
}

EVENT_EMOJIS = {
    "Created": "",
    "Created (Admin)": "",
    "Extended": "",
    "Extended (User)": "",
    "Reduced": "",
    "Deleted": "",
    "Expired": "",
    "First Use": "",
    "HWID Mismatch": "",
    "HWID Reset": "",
    "Spoof Attempt": "",
}

EXTEND_COOLDOWN_MS = 60 * 1000
EXTEND_BONUS_MS = 60 * 60 * 1000
RESET_HWID_COOLDOWN_MS = 5 * 60 * 1000
HWID_MIN_LEN = 4
HWID_MAX_LEN = 256

LINKVERTISE_STEPS = {"6hours": 1, "12hours": 2, "24hours": 3, "48hours": 4}
LINK4M_STEPS = {"12hours": 1, "24hours": 2, "48hours": 3, "72hours": 4}
DURATION_STEPS = {"linkvertise": LINKVERTISE_STEPS, "link4m": LINK4M_STEPS}
DURATION_HOURS = {"6hours": 6, "12hours": 12, "24hours": 24, "48hours": 48, "72hours": 72}

STEP_URL_TTL_MS = 60 * 60 * 1000
DONE_URL_TTL_MS = 24 * 60 * 60 * 1000

def _fmt_ts(ms):
    if not ms:
        return "N/A"
    try:
        return datetime.fromtimestamp(int(ms) / 1000, tz=timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    except Exception:
        return "N/A"

def _post_webhook(payload):
    if not DISCORD_WEBHOOK_URL:
        return
    try:
        requests.post(DISCORD_WEBHOOK_URL, json=payload, timeout=8)
    except Exception:
        pass

def notify_key_event(event_type, key_record=None, player=None, extra_fields=None):
    if not DISCORD_WEBHOOK_URL:
        return
    rec = key_record or {}
    emoji = EVENT_EMOJIS.get(event_type, "")
    color = EVENT_COLORS.get(event_type, 0xFA5050)
    fields = [
        {"name": "[Status] Key Type", "value": f"```\n{event_type}\n```", "inline": True},
        {"name": "[Key] Key", "value": f"```\n{rec.get('key', 'N/A')}\n```", "inline": True},
    ]
    if rec.get("duration"):
        fields.append({"name": "[Duration] Duration", "value": f"```\n{rec['duration']}\n```", "inline": True})
    fields.append({"name": "[Created] Key Creation Time", "value": f"```\n{_fmt_ts(rec.get('createdAt'))}\n```", "inline": False})
    fields.append({"name": "[Expire] Expires Until", "value": f"```\n{_fmt_ts(rec.get('expireAt'))}\n```", "inline": False})
    if rec.get("hwid"):
        fields.append({"name": "[HWID] HWID", "value": f"```\n{rec['hwid']}\n```", "inline": False})
    if rec.get("ip"):
        fields.append({"name": "[IP] IP", "value": f"```\n{rec['ip']}\n```", "inline": True})
    if extra_fields:
        fields.extend(extra_fields)
    embed = {
        "title": f"{emoji} Lonely Hub Key {event_type}",
        "color": color,
        "fields": fields,
        "footer": {"text": "Lonely Hub Key System"},
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    if player and player.get("userId"):
        uid = str(player["userId"])
        embed["title"] = f"{emoji} Roblox Account · {event_type}"
        embed["url"] = f"https://www.roblox.com/users/{uid}"
        dn = player.get("displayName") or player.get("username") or "Unknown"
        un = player.get("username") or dn
        embed["description"] = f"Display Name: **{dn}**\nUsername: `@{un}`\nUser ID: `{uid}`"
        embed["thumbnail"] = {
            "url": f"https://www.roblox.com/headshot-thumbnail/image?userId={uid}&width=420&height=420&format=png"
        }
    payload = {
        "username": "Lonely Hub",
        "avatar_url": DISCORD_AVATAR_URL,
        "embeds": [embed],
    }
    threading.Thread(target=_post_webhook, args=(payload,), daemon=True).start()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(BASE_DIR, "config.json")
ADMINKEY_PATH = os.path.join(BASE_DIR, "adminkey.json")
DB_PATH = os.path.join(BASE_DIR, "db.json")
KEY_PATH = os.path.join(BASE_DIR, "key.json")

_lock = threading.Lock()

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(path, data):
    with _lock:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

CONFIG = load_json(CONFIG_PATH)
ADMINKEYS = load_json(ADMINKEY_PATH)

app = Flask(
    __name__,
    static_folder=os.path.join(BASE_DIR, "static"),
    template_folder=os.path.join(BASE_DIR, "templates"),
)

def base_url():
    return request.host_url.rstrip("/")

def now_ts():
    return int(time.time() * 1000)

def get_ip():
    fwd = request.headers.get("X-Forwarded-For", "")
    if fwd:
        return fwd.split(",")[0].strip()
    return request.remote_addr or "0.0.0.0"

def get_ua():
    return request.headers.get("User-Agent", "unknown")

def hmac_sig(*parts):
    raw = "|".join(str(p) for p in parts)
    return hmac.new(CONFIG["SECRET"].encode("utf-8"), raw.encode("utf-8"), hashlib.sha256).hexdigest()

def step_sig(sid, step, method, duration, issued_at):
    return hmac_sig("step", sid, step, method, duration, issued_at)

def done_sig(sid, key, issued_at):
    return hmac_sig("done", sid, key, issued_at)

def step_url(sid, step, method, duration):
    issued = now_ts()
    sig = step_sig(sid, step, method, duration, issued)
    qs = urlencode({
        "method": method,
        "duration": duration,
        "sid": sid,
        "step": step,
        "ts": issued,
        "sig": sig,
    })
    return f"{base_url()}/api/v1/getkey?{qs}"

def done_url(sid, key):
    issued = now_ts()
    sig = done_sig(sid, key, issued)
    qs = urlencode({"key": key, "sid": sid, "ts": issued, "sig": sig})
    return f"{base_url()}/api/v1/getkey/done?{qs}"

def gen_key():
    parts = [
        secrets.token_hex(4)[:7],
        secrets.token_hex(2),
        secrets.token_hex(2),
        secrets.token_hex(2),
        secrets.token_hex(2),
        secrets.token_hex(3)[:5],
    ]
    return "LonelyHub-" + "-".join(parts)

def is_blocked(ip, hwid):
    db = load_json(DB_PATH)
    blocked = db.get("blocked", {})
    for k in (ip, hwid):
        if not k:
            continue
        rec = blocked.get(k)
        if rec and rec.get("until", 0) > now_ts():
            return True, rec.get("until", 0)
    return False, 0

def add_block(ip, hwid, reason="bypass_detected", hours=2):
    db = load_json(DB_PATH)
    until = now_ts() + hours * 3600 * 1000
    rec = {"until": until, "reason": reason, "ip": ip, "hwid": hwid, "createdAt": now_ts()}
    db.setdefault("blocked", {})[ip] = rec
    if hwid:
        db["blocked"][hwid] = rec
    save_json(DB_PATH, db)
    return until

def get_session(sid):
    db = load_json(DB_PATH)
    return db.get("sessions", {}).get(sid)

def set_session(sid, sess):
    db = load_json(DB_PATH)
    db.setdefault("sessions", {})[sid] = sess
    save_json(DB_PATH, db)

def trap_block():
    ip = get_ip()
    hwid = request.headers.get("X-HWID", "") or request.args.get("hwid", "")
    until = add_block(ip, hwid, reason="bypass_detected", hours=2)
    return jsonify({"status": "bypass_detected", "blockedUntil": until, "redirect": "/blocked"})

def admin_header_ok():
    for k, v in ADMINKEYS.items():
        got = request.headers.get(k, "")
        if got != v:
            return False
    return True

def admin_session_valid():
    token = request.cookies.get("admin_token", "")
    if not token:
        return False
    db = load_json(DB_PATH)
    sess = db.get("admin_sessions", {}).get(token)
    if not sess:
        return False
    if sess.get("expireAt", 0) < now_ts():
        return False
    return True

def admin_session_create():
    token = secrets.token_hex(24)
    db = load_json(DB_PATH)
    db.setdefault("admin_sessions", {})[token] = {
        "createdAt": now_ts(),
        "expireAt": now_ts() + 5 * 60 * 1000,
        "ip": get_ip(),
    }
    save_json(DB_PATH, db)
    return token

def cleanup_admin_sessions():
    db = load_json(DB_PATH)
    sessions = db.get("admin_sessions", {})
    cleaned = {k: v for k, v in sessions.items() if v.get("expireAt", 0) > now_ts()}
    db["admin_sessions"] = cleaned
    save_json(DB_PATH, db)

def ensure_key_for_session(sess, sid):
    if sess.get("key"):
        return sess["key"]
    duration = sess.get("duration", "24hours")
    hours = DURATION_HOURS.get(duration, 24)
    new_key = gen_key()
    expire_at = now_ts() + hours * 3600 * 1000
    keys_db = load_json(KEY_PATH)
    new_record = {
        "key": new_key,
        "type": duration,
        "hwid": "",
        "ip": sess.get("ip", ""),
        "createdAt": now_ts(),
        "expireAt": expire_at,
        "duration": duration,
        "userId": sess.get("userId") or sid,
        "method": sess.get("method"),
        "lastExtendedAt": 0,
        "lastResetHwidAt": 0,
        "resetCount": 0,
        "extendCount": 0,
        "mismatchCount": 0,
        "boundIp": "",
        "boundAt": 0,
    }
    keys_db.setdefault("keys", {})[new_key] = new_record
    save_json(KEY_PATH, keys_db)
    sess["key"] = new_key
    sess["expireAt"] = expire_at
    sess["completedAt"] = now_ts()
    sess["flag"] = "completed"
    set_session(sid, sess)
    notify_key_event("Created", new_record)
    return new_key

@app.after_request
def _no_cache(resp):
    p = request.path or ""
    if p.endswith(".css") or p.endswith(".js") or p.endswith(".html") or p == "/" or p.startswith("/getkey") or p.startswith("/mykeys") or p.startswith("/api/v1/getkey"):
        resp.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        resp.headers["Pragma"] = "no-cache"
        resp.headers["Expires"] = "0"
    resp.headers["X-Content-Type-Options"] = "nosniff"
    resp.headers["X-Frame-Options"] = "SAMEORIGIN"
    resp.headers["Referrer-Policy"] = "no-referrer"
    return resp

@app.route("/")
def index_page():
    return send_from_directory(app.static_folder, "index.html")

@app.route("/static/<path:fname>")
def static_files(fname):
    return send_from_directory(app.static_folder, fname)

@app.route("/getkey")
def getkey_page():
    blocked, until = is_blocked(get_ip(), request.args.get("hwid", ""))
    if blocked:
        return redirect(url_for("blocked_page"))
    return render_template(
        "getkey.html",
        cf_sitekey=CONFIG["CLOUDFLARE_SITEKEY"],
        hcaptcha_sitekey=CONFIG["HCAPTCHA_SITEKEY"],
    )

@app.route("/verify")
def verify_resume_page():
    sid_q = request.args.get("sid", "")
    step_q = request.args.get("step", "")
    return render_template("verify.html", sid_q=sid_q, step_q=step_q)

@app.route("/getkey/step/<sid>/<int:step>")
def step_page_legacy(sid, step):
    sess = get_session(sid)
    if not sess or sess.get("purpose") == "reset_hwid":
        return redirect(url_for("getkey_page"))
    return redirect(step_url(sid, step, sess.get("method", "linkvertise"), sess.get("duration", "24hours")))

@app.route("/getkey/finish/<sid>")
def finish_page_legacy(sid):
    sess = get_session(sid)
    if not sess or sess.get("purpose") == "reset_hwid":
        return redirect(url_for("getkey_page"))
    blocked, until = is_blocked(sess.get("ip", ""), sess.get("hwid", ""))
    if blocked:
        return redirect(url_for("blocked_page"))
    total = sess.get("totalSteps", 1)
    if total > 1 and sess.get("step", 0) != total - 1:
        return redirect(url_for("getkey_page"))
    new_key = ensure_key_for_session(sess, sid)
    return redirect(done_url(sid, new_key))

@app.route("/api/v1/getkey", methods=["GET"])
def api_v1_getkey():
    sid = (request.args.get("sid") or "").strip()
    step_str = (request.args.get("step") or "").strip()
    method_arg = (request.args.get("method") or "").strip()
    duration_arg = (request.args.get("duration") or "").strip()
    sig = (request.args.get("sig") or "").strip()
    ts_str = (request.args.get("ts") or "").strip()
    if not sid or not step_str or not sig or not ts_str or not method_arg or not duration_arg:
        return redirect(url_for("getkey_page"))
    try:
        step = int(step_str)
        issued = int(ts_str)
    except Exception:
        return redirect(url_for("getkey_page"))
    sess = get_session(sid)
    if not sess or sess.get("purpose") == "reset_hwid":
        return redirect(url_for("getkey_page"))
    blocked, until = is_blocked(sess.get("ip", ""), sess.get("hwid", ""))
    if blocked:
        return redirect(url_for("blocked_page"))
    if sess.get("method") != method_arg or sess.get("duration") != duration_arg:
        return redirect(url_for("getkey_page"))
    expected = step_sig(sid, step, method_arg, duration_arg, issued)
    if not hmac.compare_digest(expected, sig):
        until = add_block(sess.get("ip", ""), sess.get("hwid", ""), reason="signature_mismatch")
        return redirect(url_for("blocked_page"))
    if now_ts() - issued > STEP_URL_TTL_MS:
        return redirect(url_for("getkey_page"))
    total = sess.get("totalSteps", 1)
    if step < 1 or step > total:
        return redirect(url_for("getkey_page"))
    if step != sess.get("step", 0) + 1:
        return redirect(url_for("getkey_page"))
    if step == total:
        sess["step"] = step
        sess["lastStepTime"] = now_ts()
        set_session(sid, sess)
        new_key = ensure_key_for_session(sess, sid)
        return redirect(done_url(sid, new_key))
    return render_template(
        "step.html",
        sid=sid,
        step=step,
        total=total,
        method=sess.get("method", "linkvertise"),
        duration=sess.get("duration", ""),
        cf_sitekey=CONFIG["CLOUDFLARE_SITEKEY"],
        hcaptcha_sitekey=CONFIG["HCAPTCHA_SITEKEY"],
    )

@app.route("/api/v1/getkey/done", methods=["GET"])
def api_v1_getkey_done():
    raw_key = (request.args.get("key") or "").strip()
    sid = (request.args.get("sid") or "").strip()
    sig = (request.args.get("sig") or "").strip()
    ts_str = (request.args.get("ts") or "").strip()
    verified = False
    rec = None
    if raw_key and sid and sig and ts_str:
        try:
            issued = int(ts_str)
            expected = done_sig(sid, raw_key, issued)
            if hmac.compare_digest(expected, sig) and (now_ts() - issued) <= DONE_URL_TTL_MS:
                sess = get_session(sid)
                if sess and sess.get("key") == raw_key:
                    keys_db = load_json(KEY_PATH)
                    rec = keys_db.get("keys", {}).get(raw_key)
                    if rec:
                        verified = True
        except Exception:
            verified = False
            rec = None
    method = (rec or {}).get("method") or (rec or {}).get("duration") or ""
    duration = (rec or {}).get("duration") or ""
    expire_at = (rec or {}).get("expireAt", 0)
    return render_template(
        "done.html",
        key=raw_key,
        verified=verified,
        method=method,
        duration=duration,
        expire_at=expire_at,
    )

@app.route("/mykeys")
def mykeys_page():
    return render_template("mykeys.html")

@app.route("/blocked")
def blocked_page():
    return render_template("blocked.html")

@app.route("/api/v1/auth/check", methods=["GET", "POST"])
def api_check_key():
    if request.method == "POST":
        body = request.get_json(silent=True) or {}
        key = body.get("key", "")
    else:
        key = request.args.get("key", "")
    key = (key or "").strip()
    if not key:
        return jsonify({"success": False, "status": "missing_key"}), 400
    keys_db = load_json(KEY_PATH)
    rec = keys_db.get("keys", {}).get(key)
    if not rec:
        return jsonify({"success": False, "status": "not_found", "key": key}), 404
    now = now_ts()
    expire_at = rec.get("expireAt", 0)
    created_at = rec.get("createdAt", 0)
    expired = expire_at and expire_at < now
    last_ext = rec.get("lastExtendedAt", 0) or 0
    last_rst = rec.get("lastResetHwidAt", 0) or 0
    ext_wait = max(0, EXTEND_COOLDOWN_MS - (now - last_ext)) if last_ext else 0
    rst_wait = max(0, RESET_HWID_COOLDOWN_MS - (now - last_rst)) if last_rst else 0
    bound_hwid = rec.get("hwid", "") or ""
    return jsonify({
        "success": True,
        "status": "expired" if expired else "active",
        "key": key,
        "duration": rec.get("duration"),
        "createdAt": created_at,
        "createdAtIso": _fmt_ts(created_at),
        "expireAt": expire_at,
        "expireAtIso": _fmt_ts(expire_at),
        "msRemaining": max(0, expire_at - now),
        "secondsRemaining": max(0, (expire_at - now) // 1000),
        "hwid": bound_hwid,
        "hwidBound": bool(bound_hwid),
        "hwidPreview": (bound_hwid[:6] + "***") if bound_hwid else "",
        "userId": rec.get("userId"),
        "firstUsedAt": rec.get("firstUsedAt"),
        "lastExtendedAt": last_ext,
        "lastResetHwidAt": last_rst,
        "extendCooldownMs": EXTEND_COOLDOWN_MS,
        "extendWaitMs": ext_wait,
        "extendWaitSec": int(ext_wait // 1000) + (1 if ext_wait % 1000 else 0),
        "extendCount": rec.get("extendCount", 0) or 0,
        "resetHwidCooldownMs": RESET_HWID_COOLDOWN_MS,
        "resetHwidWaitMs": rst_wait,
        "resetHwidWaitSec": int(rst_wait // 1000) + (1 if rst_wait % 1000 else 0),
        "resetCount": rec.get("resetCount", 0) or 0,
        "mismatchCount": rec.get("mismatchCount", 0) or 0,
    })

def create_linkvertise_link(user_id, target_url):
    safe_chars = ";,/?:@&=+$-_.!~*'()#"
    encoded = quote(target_url, safe=safe_chars)
    b64 = base64.b64encode(encoded.encode("utf-8")).decode("ascii")
    rnd = random.randint(100, 999)
    return f"https://link-to.net/{user_id}/{rnd}/dynamic?r={b64}"

def create_link4m_link(api_token, long_url):
    api_url = f"https://link4m.co/api-shorten/v2?api={api_token}&url={quote(long_url, safe='')}"
    try:
        r = requests.get(api_url, timeout=15)
        data = r.json()
        if data.get("status") == "success":
            return data.get("shortenedUrl")
    except Exception:
        return None
    return None

def build_short_link(method, target_url):
    if method == "linkvertise":
        return create_linkvertise_link(CONFIG.get("LINKVERTISE_USER_ID", ""), target_url)
    if method == "link4m":
        return create_link4m_link(CONFIG.get("LINK4M_API", ""), target_url)
    return None

@app.route("/api/v1/auth/getkey/start", methods=["POST"])
def api_start():
    body = request.get_json(silent=True) or {}
    hwid = body.get("hwid", "") or request.headers.get("X-HWID", "")
    duration = (body.get("duration") or "").strip()
    method = body.get("method", "linkvertise")
    cf_token = body.get("cf_token", "")
    hc_token = body.get("hcaptcha_token", "")
    ip = get_ip()
    blocked, until = is_blocked(ip, hwid)
    if blocked:
        return jsonify({"status": "blocked", "blockedUntil": until}), 403
    steps_map = DURATION_STEPS.get(method)
    if not steps_map or duration not in steps_map:
        return jsonify({"status": "error", "message": "invalid method or duration"}), 400
    if not verify_cloudflare(cf_token):
        until = add_block(ip, hwid)
        return jsonify({"status": "verify_failed", "blockedUntil": until, "which": "cloudflare"}), 403
    if not verify_hcaptcha(hc_token):
        until = add_block(ip, hwid)
        return jsonify({"status": "verify_failed", "blockedUntil": until, "which": "hcaptcha"}), 403
    total_steps = steps_map[duration]
    sid = secrets.token_hex(16)
    uid = "user_" + secrets.token_hex(6)
    sess = {
        "sessionId": sid,
        "userId": uid,
        "hwid": hwid,
        "ip": ip,
        "userAgent": get_ua(),
        "startTime": now_ts(),
        "lastStepTime": now_ts(),
        "step": 0,
        "totalSteps": total_steps,
        "flag": "ok",
        "blockedUntil": 0,
        "duration": duration,
        "method": method,
        "key": None,
    }
    set_session(sid, sess)
    if total_steps <= 1:
        new_key = ensure_key_for_session(sess, sid)
        target = done_url(sid, new_key)
    else:
        target = step_url(sid, 1, method, duration)
    short = build_short_link(method, target)
    if not short:
        return jsonify({"status": "error", "message": "failed to create short link"}), 500
    return jsonify({
        "status": "ok",
        "sessionId": sid,
        "userId": uid,
        "totalSteps": total_steps,
        "shortUrl": short,
    })

@app.route("/api/v1/auth/getkey/continue", methods=["POST"])
def api_continue():
    body = request.get_json(silent=True) or {}
    sid = body.get("sessionId", "")
    step = int(body.get("step", 0))
    cf_token = body.get("cf_token", "")
    hc_token = body.get("hcaptcha_token", "")
    sess = get_session(sid)
    if not sess:
        return jsonify({"status": "invalid_session"}), 400
    blocked, until = is_blocked(sess.get("ip", ""), sess.get("hwid", ""))
    if blocked:
        return jsonify({"status": "blocked", "blockedUntil": until}), 403
    total = sess.get("totalSteps", 1)
    expected = sess.get("step", 0) + 1
    if step != expected or step < 1 or step >= total:
        until = add_block(sess.get("ip", ""), sess.get("hwid", ""))
        sess["flag"] = "bypass_detected"
        sess["blockedUntil"] = until
        set_session(sid, sess)
        return jsonify({"status": "bypass_detected", "blockedUntil": until}), 403
    if not verify_cloudflare(cf_token):
        until = add_block(sess.get("ip", ""), sess.get("hwid", ""))
        return jsonify({"status": "verify_failed", "blockedUntil": until, "which": "cloudflare"}), 403
    if not verify_hcaptcha(hc_token):
        until = add_block(sess.get("ip", ""), sess.get("hwid", ""))
        return jsonify({"status": "verify_failed", "blockedUntil": until, "which": "hcaptcha"}), 403
    sess["step"] = step
    sess["lastStepTime"] = now_ts()
    set_session(sid, sess)
    method = sess.get("method", "linkvertise")
    duration = sess.get("duration", "24hours")
    if step + 1 >= total:
        new_key = ensure_key_for_session(sess, sid)
        target = done_url(sid, new_key)
        is_final = True
    else:
        target = step_url(sid, step + 1, method, duration)
        is_final = False
    short = build_short_link(method, target)
    if not short:
        return jsonify({"status": "error", "message": "failed to create short link"}), 500
    return jsonify({"status": "ok", "step": step, "isFinal": is_final, "shortUrl": short})

@app.route("/api/v1/auth/getkey", methods=["GET"])
def api_check():
    if request.args.get("step") == "done" or request.args.get("complete") == "true":
        return trap_block()
    arg = request.args.get("arg", "")
    if arg == "check":
        sid = request.args.get("sessionId", "")
        sess = get_session(sid)
        if not sess:
            return jsonify({"status": "invalid_session"}), 400
        return jsonify({
            "status": "ok",
            "step": sess.get("step", 0),
            "flag": sess.get("flag", "ok"),
            "verified": sess.get("verified", {}),
            "key": sess.get("key"),
        })
    return jsonify({"status": "ok", "service": "LonelyHub GetKey API", "baseUrl": base_url()})

@app.route("/api/v1/auth/getkey/free", methods=["GET"])
def trap_free():
    return trap_block()

@app.route("/api/v1/auth/getkey/unlock", methods=["GET"])
def trap_unlock():
    return trap_block()

def verify_cloudflare(token):
    if not token:
        return False
    try:
        r = requests.post(
            "https://challenges.cloudflare.com/turnstile/v0/siteverify",
            data={"secret": CONFIG["CLOUDFLARE_SECRET"], "response": token, "remoteip": get_ip()},
            timeout=10,
        )
        data = r.json()
        return bool(data.get("success"))
    except Exception:
        return False

def verify_hcaptcha(token):
    if not token:
        return False
    try:
        r = requests.post(
            "https://hcaptcha.com/siteverify",
            data={"secret": CONFIG["HCAPTCHA_SECRET"], "response": token, "remoteip": get_ip()},
            timeout=10,
        )
        data = r.json()
        return bool(data.get("success"))
    except Exception:
        return False

@app.route("/api/v1/auth/getkey/shorten", methods=["GET"])
def api_shorten():
    url = request.args.get("url", "")
    if not url:
        return jsonify({"status": "error", "message": "missing url"}), 400
    try:
        api_url = f"https://link4m.co/api-shorten/v2?api={CONFIG['LINK4M_API']}&url={url}"
        r = requests.get(api_url, timeout=15)
        result = r.json()
        if result.get("status") != "success":
            return jsonify({"status": "error", "message": result.get("message", "shorten failed")}), 500
        return jsonify({"status": "success", "shortenedUrl": result.get("shortenedUrl")})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/api/v1/auth/key/validate", methods=["GET", "POST"])
def api_validate_key():
    player = None
    if request.method == "POST":
        body = request.get_json(silent=True) or {}
        key = body.get("key", "")
        hwid = body.get("hwid", "") or request.headers.get("X-HWID", "")
        if body.get("userId"):
            player = {
                "userId": body.get("userId"),
                "displayName": body.get("displayName", ""),
                "username": body.get("username", ""),
            }
    else:
        key = request.args.get("key", "")
        hwid = request.args.get("hwid", "") or request.headers.get("X-HWID", "")
        if request.args.get("userId"):
            player = {
                "userId": request.args.get("userId"),
                "displayName": request.args.get("displayName", ""),
                "username": request.args.get("username", ""),
            }
    if not key:
        return jsonify({"success": False, "status": "missing_key"}), 400
    keys_db = load_json(KEY_PATH)
    rec = keys_db.get("keys", {}).get(key)
    if not rec:
        return jsonify({"success": False, "status": "invalid_key"}), 404
    if rec.get("expireAt", 0) < now_ts():
        if not rec.get("notifiedExpired"):
            rec["notifiedExpired"] = True
            save_json(KEY_PATH, keys_db)
            notify_key_event("Expired", rec, player=player)
        return jsonify({"success": False, "status": "expired", "expireAt": rec.get("expireAt", 0)}), 410
    hwid_clean = (hwid or "").strip()
    if not hwid_clean:
        return jsonify({"success": False, "status": "missing_hwid", "message": "HWID required"}), 400
    if len(hwid_clean) < HWID_MIN_LEN or len(hwid_clean) > HWID_MAX_LEN:
        notify_key_event("Spoof Attempt", rec, player=player, extra_fields=[
            {"name": "[Suspicious HWID]", "value": f"```\nlen={len(hwid_clean)} val={hwid_clean[:48]}\n```", "inline": False},
        ])
        return jsonify({"success": False, "status": "invalid_hwid"}), 400
    if not all(c.isalnum() or c in "-_:.{}/" for c in hwid_clean):
        notify_key_event("Spoof Attempt", rec, player=player, extra_fields=[
            {"name": "[Bad HWID Charset]", "value": f"```\n{hwid_clean[:80]}\n```", "inline": False},
        ])
        return jsonify({"success": False, "status": "invalid_hwid"}), 400
    if rec.get("hwid") and rec["hwid"] != hwid_clean:
        rec["mismatchCount"] = (rec.get("mismatchCount", 0) or 0) + 1
        save_json(KEY_PATH, keys_db)
        notify_key_event("HWID Mismatch", rec, player=player, extra_fields=[
            {"name": "[Attempted HWID]", "value": f"```\n{hwid_clean}\n```", "inline": False},
            {"name": "[Attempt IP]", "value": f"```\n{get_ip()}\n```", "inline": True},
            {"name": "[Mismatch Count]", "value": f"```\n{rec['mismatchCount']}\n```", "inline": True},
        ])
        return jsonify({
            "success": False,
            "status": "hwid_mismatch",
            "message": "Hwid not mismatch",
            "boundHwid": (rec.get("hwid", "")[:6] + "***") if rec.get("hwid") else "",
        }), 403
    dirty = False
    if not rec.get("hwid"):
        rec["hwid"] = hwid_clean
        rec["boundIp"] = get_ip()
        rec["boundAt"] = now_ts()
        dirty = True
    if not rec.get("firstUsedAt"):
        rec["firstUsedAt"] = now_ts()
        if player:
            rec["firstUsedBy"] = player
        dirty = True
        if dirty:
            save_json(KEY_PATH, keys_db)
        notify_key_event("First Use", rec, player=player)
    elif dirty:
        save_json(KEY_PATH, keys_db)
    return jsonify({
        "success": True,
        "status": "valid",
        "key": key,
        "type": rec.get("type") or rec.get("duration", ""),
        "hwid": rec.get("hwid", ""),
        "expireAt": rec.get("expireAt", 0),
        "duration": rec.get("duration", ""),
        "remainingMs": rec.get("expireAt", 0) - now_ts(),
    })

@app.route("/api/v1/auth/key/extend", methods=["POST"])
def api_extend_key():
    body = request.get_json(silent=True) or {}
    key = (body.get("key") or "").strip()
    hwid = (body.get("hwid") or request.headers.get("X-HWID") or "").strip()
    if not key:
        return jsonify({"success": False, "status": "missing_key"}), 400
    keys_db = load_json(KEY_PATH)
    rec = keys_db.get("keys", {}).get(key)
    if not rec:
        return jsonify({"success": False, "status": "invalid_key"}), 404
    if rec.get("expireAt", 0) < now_ts():
        return jsonify({"success": False, "status": "expired"}), 410
    if rec.get("hwid") and hwid and rec["hwid"] != hwid:
        return jsonify({"success": False, "status": "hwid_mismatch", "message": "Hwid not mismatch"}), 403
    last = rec.get("lastExtendedAt", 0) or 0
    elapsed = now_ts() - last
    if last and elapsed < EXTEND_COOLDOWN_MS:
        wait_ms = EXTEND_COOLDOWN_MS - elapsed
        return jsonify({
            "success": False,
            "status": "cooldown",
            "waitMs": wait_ms,
            "waitSec": int(wait_ms // 1000) + 1,
            "cooldownMs": EXTEND_COOLDOWN_MS,
        }), 429
    base = max(rec.get("expireAt", 0), now_ts())
    rec["expireAt"] = base + EXTEND_BONUS_MS
    rec["lastExtendedAt"] = now_ts()
    rec["extendCount"] = (rec.get("extendCount", 0) or 0) + 1
    save_json(KEY_PATH, keys_db)
    notify_key_event("Extended (User)", rec, extra_fields=[
        {"name": "[Bonus]", "value": "```\n+1h\n```", "inline": True},
        {"name": "[Extend Count]", "value": f"```\n{rec['extendCount']}\n```", "inline": True},
    ])
    return jsonify({
        "success": True,
        "status": "ok",
        "key": key,
        "expireAt": rec["expireAt"],
        "msRemaining": rec["expireAt"] - now_ts(),
        "lastExtendedAt": rec["lastExtendedAt"],
        "cooldownMs": EXTEND_COOLDOWN_MS,
        "nextExtendAt": rec["lastExtendedAt"] + EXTEND_COOLDOWN_MS,
    })

@app.route("/api/v1/auth/key/reset-hwid", methods=["POST"])
def api_reset_hwid():
    body = request.get_json(silent=True) or {}
    key = (body.get("key") or "").strip()
    sid = (body.get("sessionId") or "").strip()
    if not key:
        return jsonify({"success": False, "status": "missing_key"}), 400
    if not sid:
        return jsonify({"success": False, "status": "missing_session"}), 400
    sess = get_session(sid)
    if not sess:
        return jsonify({"success": False, "status": "invalid_session"}), 400
    if sess.get("resetUsed"):
        return jsonify({"success": False, "status": "session_used"}), 400
    if sess.get("resetTargetKey") and sess["resetTargetKey"] != key:
        return jsonify({"success": False, "status": "session_key_mismatch"}), 400
    verified = sess.get("verified", {}) or {}
    if not verified.get("cloudflare") or not verified.get("hcaptcha"):
        return jsonify({"success": False, "status": "verify_incomplete"}), 403
    keys_db = load_json(KEY_PATH)
    rec = keys_db.get("keys", {}).get(key)
    if not rec:
        return jsonify({"success": False, "status": "invalid_key"}), 404
    if rec.get("expireAt", 0) < now_ts():
        return jsonify({"success": False, "status": "expired"}), 410
    last = rec.get("lastResetHwidAt", 0) or 0
    elapsed = now_ts() - last
    if last and elapsed < RESET_HWID_COOLDOWN_MS:
        wait_ms = RESET_HWID_COOLDOWN_MS - elapsed
        return jsonify({
            "success": False,
            "status": "cooldown",
            "waitMs": wait_ms,
            "waitSec": int(wait_ms // 1000) + 1,
            "cooldownMs": RESET_HWID_COOLDOWN_MS,
        }), 429
    old_hwid = rec.get("hwid", "")
    rec["hwid"] = ""
    rec["boundIp"] = ""
    rec["boundAt"] = 0
    rec["lastResetHwidAt"] = now_ts()
    rec["resetCount"] = (rec.get("resetCount", 0) or 0) + 1
    save_json(KEY_PATH, keys_db)
    sess["resetUsed"] = True
    sess["resetCompletedAt"] = now_ts()
    set_session(sid, sess)
    notify_key_event("HWID Reset", rec, extra_fields=[
        {"name": "[Old HWID]", "value": f"```\n{old_hwid or 'none'}\n```", "inline": False},
        {"name": "[Reset Count]", "value": f"```\n{rec['resetCount']}\n```", "inline": True},
        {"name": "[Resetter IP]", "value": f"```\n{get_ip()}\n```", "inline": True},
    ])
    return jsonify({
        "success": True,
        "status": "ok",
        "key": key,
        "lastResetHwidAt": rec["lastResetHwidAt"],
        "cooldownMs": RESET_HWID_COOLDOWN_MS,
        "nextResetAt": rec["lastResetHwidAt"] + RESET_HWID_COOLDOWN_MS,
    })

@app.route("/api/v1/auth/key/reset-hwid/start", methods=["POST"])
def api_reset_hwid_start():
    body = request.get_json(silent=True) or {}
    key = (body.get("key") or "").strip()
    if not key:
        return jsonify({"success": False, "status": "missing_key"}), 400
    keys_db = load_json(KEY_PATH)
    rec = keys_db.get("keys", {}).get(key)
    if not rec:
        return jsonify({"success": False, "status": "invalid_key"}), 404
    if rec.get("expireAt", 0) < now_ts():
        return jsonify({"success": False, "status": "expired"}), 410
    last = rec.get("lastResetHwidAt", 0) or 0
    elapsed = now_ts() - last
    if last and elapsed < RESET_HWID_COOLDOWN_MS:
        wait_ms = RESET_HWID_COOLDOWN_MS - elapsed
        return jsonify({
            "success": False,
            "status": "cooldown",
            "waitMs": wait_ms,
            "waitSec": int(wait_ms // 1000) + 1,
            "cooldownMs": RESET_HWID_COOLDOWN_MS,
        }), 429
    sid = secrets.token_urlsafe(24)
    set_session(sid, {
        "createdAt": now_ts(),
        "ip": get_ip(),
        "ua": request.headers.get("User-Agent", ""),
        "purpose": "reset_hwid",
        "resetTargetKey": key,
        "verified": {"cloudflare": False, "hcaptcha": False},
        "step": 0,
        "flag": "ok",
    })
    return jsonify({
        "success": True,
        "status": "ok",
        "sessionId": sid,
        "key": key,
        "cloudflareSiteKey": CONFIG["CLOUDFLARE_SITEKEY"],
        "hcaptchaSiteKey": CONFIG["HCAPTCHA_SITEKEY"],
    })

@app.route("/api/v1/auth/key/reset-hwid/verify", methods=["POST"])
def api_reset_hwid_verify():
    body = request.get_json(silent=True) or {}
    sid = (body.get("sessionId") or "").strip()
    kind = (body.get("kind") or "").strip()
    token = body.get("token", "")
    sess = get_session(sid)
    if not sess:
        return jsonify({"success": False, "status": "invalid_session"}), 400
    if sess.get("purpose") != "reset_hwid":
        return jsonify({"success": False, "status": "wrong_purpose"}), 400
    sess.setdefault("verified", {"cloudflare": False, "hcaptcha": False})
    if kind == "cloudflare":
        if not verify_cloudflare(token):
            return jsonify({"success": False, "status": "cloudflare_failed"}), 403
        sess["verified"]["cloudflare"] = True
        sess["step"] = max(sess.get("step", 0), 1)
    elif kind == "hcaptcha":
        if not sess["verified"].get("cloudflare"):
            return jsonify({"success": False, "status": "out_of_order"}), 400
        if not verify_hcaptcha(token):
            return jsonify({"success": False, "status": "hcaptcha_failed"}), 403
        sess["verified"]["hcaptcha"] = True
        sess["step"] = max(sess.get("step", 0), 2)
    else:
        return jsonify({"success": False, "status": "unknown_kind"}), 400
    set_session(sid, sess)
    return jsonify({
        "success": True,
        "status": "ok",
        "step": sess["step"],
        "verified": sess["verified"],
    })

@app.route("/resethwid", methods=["GET"])
def reset_hwid_page():
    target_key = (request.args.get("key") or "").strip()
    return render_template(
        "resethwid.html",
        target_key=target_key,
        cf_sitekey=CONFIG["CLOUDFLARE_SITEKEY"],
        hcaptcha_sitekey=CONFIG["HCAPTCHA_SITEKEY"],
    )

@app.route("/api/v2/auth/dev/manager/key.json", methods=["GET"])
def api_dev_keys():
    if not admin_header_ok():
        return jsonify({"status": "unauthorized", "message": "invalid headers"}), 401
    keys_db = load_json(KEY_PATH)
    db = load_json(DB_PATH)
    return jsonify({
        "status": "ok",
        "keys": keys_db.get("keys", {}),
        "blocked": db.get("blocked", {}),
        "sessions": db.get("sessions", {}),
        "baseUrl": base_url(),
    })

@app.route("/api/v3/auth/admin/manager.html", methods=["GET", "POST"])
def admin_manager():
    cleanup_admin_sessions()
    if request.method == "POST":
        if admin_header_ok():
            token = admin_session_create()
            resp = make_response(jsonify({"status": "ok", "token": token, "expireIn": 300}))
            resp.set_cookie("admin_token", token, max_age=300, httponly=True, samesite="Lax")
            return resp
        return jsonify({"status": "unauthorized"}), 401
    if admin_session_valid():
        return redirect("/api/v3/auth/admin/key.html")
    return render_template("admin_login.html")

@app.route("/api/v3/auth/admin/key.html", methods=["GET"])
def admin_panel():
    cleanup_admin_sessions()
    if not admin_session_valid():
        return redirect("/api/v3/auth/admin/manager.html")
    return render_template("admin_panel.html")

@app.route("/api/v3/auth/admin/api/keys", methods=["GET"])
def admin_list_keys():
    cleanup_admin_sessions()
    if not admin_session_valid():
        return jsonify({"status": "unauthorized"}), 401
    keys_db = load_json(KEY_PATH)
    db = load_json(DB_PATH)
    return jsonify({
        "status": "ok",
        "keys": keys_db.get("keys", {}),
        "blocked": db.get("blocked", {}),
    })

@app.route("/api/v3/auth/admin/api/keys/add", methods=["POST"])
def admin_add_key():
    cleanup_admin_sessions()
    if not admin_session_valid():
        return jsonify({"status": "unauthorized"}), 401
    body = request.get_json(silent=True) or {}
    hours = int(body.get("hours", 24))
    hwid = body.get("hwid", "")
    new_key = body.get("key") or gen_key()
    keys_db = load_json(KEY_PATH)
    new_record = {
        "key": new_key,
        "hwid": hwid,
        "ip": "",
        "createdAt": now_ts(),
        "expireAt": now_ts() + hours * 3600 * 1000,
        "duration": f"{hours}hours",
        "userId": "admin_added",
    }
    keys_db.setdefault("keys", {})[new_key] = new_record
    save_json(KEY_PATH, keys_db)
    notify_key_event("Created (Admin)", new_record)
    return jsonify({"status": "ok", "key": new_key})

@app.route("/api/v3/auth/admin/api/keys/extend", methods=["POST"])
def admin_extend_key():
    cleanup_admin_sessions()
    if not admin_session_valid():
        return jsonify({"status": "unauthorized"}), 401
    body = request.get_json(silent=True) or {}
    key = body.get("key", "")
    hours = int(body.get("hours", 24))
    keys_db = load_json(KEY_PATH)
    if key not in keys_db.get("keys", {}):
        return jsonify({"status": "not_found"}), 404
    keys_db["keys"][key]["expireAt"] += hours * 3600 * 1000
    save_json(KEY_PATH, keys_db)
    notify_key_event("Extended", keys_db["keys"][key], extra_fields=[
        {"name": "[Hours Added]", "value": f"```\n+{hours}h\n```", "inline": True},
    ])
    return jsonify({"status": "ok", "key": key, "expireAt": keys_db["keys"][key]["expireAt"]})

@app.route("/api/v3/auth/admin/api/keys/reduce", methods=["POST"])
def admin_reduce_key():
    cleanup_admin_sessions()
    if not admin_session_valid():
        return jsonify({"status": "unauthorized"}), 401
    body = request.get_json(silent=True) or {}
    key = body.get("key", "")
    hours = int(body.get("hours", 1))
    keys_db = load_json(KEY_PATH)
    if key not in keys_db.get("keys", {}):
        return jsonify({"status": "not_found"}), 404
    keys_db["keys"][key]["expireAt"] -= hours * 3600 * 1000
    save_json(KEY_PATH, keys_db)
    notify_key_event("Reduced", keys_db["keys"][key], extra_fields=[
        {"name": "[Hours Removed]", "value": f"```\n-{hours}h\n```", "inline": True},
    ])
    return jsonify({"status": "ok", "key": key, "expireAt": keys_db["keys"][key]["expireAt"]})

@app.route("/api/v3/auth/admin/api/keys/delete", methods=["POST"])
def admin_delete_key():
    cleanup_admin_sessions()
    if not admin_session_valid():
        return jsonify({"status": "unauthorized"}), 401
    body = request.get_json(silent=True) or {}
    key = body.get("key", "")
    keys_db = load_json(KEY_PATH)
    if key in keys_db.get("keys", {}):
        deleted_record = dict(keys_db["keys"][key])
        del keys_db["keys"][key]
        save_json(KEY_PATH, keys_db)
        notify_key_event("Deleted", deleted_record)
        return jsonify({"status": "ok"})
    return jsonify({"status": "not_found"}), 404

@app.route("/api/v3/auth/admin/api/blocked/clear", methods=["POST"])
def admin_clear_block():
    cleanup_admin_sessions()
    if not admin_session_valid():
        return jsonify({"status": "unauthorized"}), 401
    body = request.get_json(silent=True) or {}
    target = body.get("target", "")
    db = load_json(DB_PATH)
    if target in db.get("blocked", {}):
        del db["blocked"][target]
        save_json(DB_PATH, db)
        return jsonify({"status": "ok"})
    return jsonify({"status": "not_found"}), 404

@app.errorhandler(404)
def not_found(e):
    return jsonify({"status": "not_found", "path": request.path}), 404

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
