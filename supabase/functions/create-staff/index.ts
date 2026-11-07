// Shree Sawriya Solutions: naya staff account banana (sirf Admin).
// Public signup band hai (security ke liye), isliye account yahan server par
// service key se banta hai. Caller ka login check hota hai aur woh Admin hona chahiye.
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const reply = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return reply(405, { error: "Sirf POST allowed hai." });

  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  // 1) Kaun bula raha hai? Login hona chahiye aur role = admin.
  const jwt = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!jwt) return reply(401, { error: "Pehle login karein." });
  const { data: who, error: whoErr } = await admin.auth.getUser(jwt);
  if (whoErr || !who?.user) return reply(401, { error: "Login expire ho gaya. Dobara login karein." });
  const { data: prof } = await admin.from("profiles").select("role").eq("id", who.user.id).maybeSingle();
  if (prof?.role !== "admin") return reply(403, { error: "Sirf Admin naya staff bana sakta hai." });

  // 2) Form check.
  let body: { name?: string; email?: string; password?: string; can_view?: boolean };
  try {
    body = await req.json();
  } catch {
    return reply(400, { error: "Galat request." });
  }
  const name = String(body.name ?? "").trim();
  const email = String(body.email ?? "").trim().toLowerCase();
  const password = String(body.password ?? "");
  if (!name) return reply(400, { error: "Naam daaliye." });
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return reply(400, { error: "Sahi email daaliye." });
  if (password.length < 6) return reply(400, { error: "Password kam se kam 6 akshar ka hona chahiye." });

  // 3) Account banao (email pehle se confirmed, taaki staff turant login kar sake).
  const { data: created, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { full_name: name },
  });
  if (error) {
    const m = (error.message ?? "").toLowerCase();
    if (m.includes("already") || m.includes("registered") || m.includes("exists")) {
      return reply(409, { error: "Yeh email pehle se registered hai." });
    }
    if (m.includes("password")) return reply(400, { error: "Password kamzor hai. Thoda lamba/mushkil rakhein." });
    console.error("createUser failed", error);
    return reply(500, { error: "Account nahi bana. Dobara try karein." });
  }

  // handle_new_user trigger profile banata hai (role staff). Naam + permission set karo.
  const uid = created.user!.id;
  await admin.from("profiles").upsert({ id: uid, full_name: name, role: "staff", can_view: body.can_view === true });

  return reply(200, { ok: true, id: uid, email });
});
