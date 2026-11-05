-- ==========================================================
--  Repair tracking: mobile number + Repair ID (DPDP security)
--  Pehle sirf mobile number se kisi ka bhi naam/phone/problem dikh jata tha.
--  Ab Repair ID (jobsheet / WhatsApp par likha, jaise SSS-0012) bhi zaroori hai,
--  aur ek number par 1 ghante mein 5 galat try ke baad lock.
-- ==========================================================

alter table public.lookup_log add column if not exists key text;      -- mobile ka md5 (asli number save nahi hota)
alter table public.lookup_log add column if not exists ok boolean;

create or replace function public.track_repairs_v2(p_mobile text, p_code text)
returns jsonb
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_cust public.customers%rowtype;
  v_digits text;
  v_code text;
  v_key text;
  v_recent int;
  v_fails int;
  v_result jsonb;
begin
  if p_mobile is null or p_mobile !~ '^[0-9]{10}$' then
    return jsonb_build_object('ok', false, 'error', 'invalid_format');
  end if;

  v_digits := regexp_replace(coalesce(p_code, ''), '\D', '', 'g');
  if v_digits = '' or length(v_digits) > 6 then
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;
  v_code := 'SSS-' || lpad(ltrim(v_digits, '0'), 4, '0');
  v_key := md5('sss-track:' || p_mobile);

  delete from public.lookup_log where looked_at < now() - interval '1 day';

  select count(*) into v_recent from public.lookup_log where looked_at > now() - interval '10 minutes';
  if v_recent >= 200 then
    return jsonb_build_object('ok', false, 'error', 'busy');
  end if;

  select count(*) into v_fails from public.lookup_log
   where key = v_key and ok = false and looked_at > now() - interval '1 hour';
  if v_fails >= 5 then
    return jsonb_build_object('ok', false, 'error', 'locked');
  end if;

  select * into v_cust from public.customers where mobile = p_mobile;
  if not found or not exists (
       select 1 from public.repairs r where r.customer_id = v_cust.id and r.repair_code = v_code) then
    insert into public.lookup_log (key, ok) values (v_key, false);
    -- Number mila ya nahi, dono mein ek jaisa jawab (taaki koi number check na kar sake)
    return jsonb_build_object('ok', true, 'repairs', '[]'::jsonb);
  end if;

  insert into public.lookup_log (key, ok) values (v_key, true);

  select jsonb_build_object(
    'ok', true,
    'first_name', split_part(v_cust.name, ' ', 1),
    'repairs', coalesce(jsonb_agg(
      jsonb_build_object(
        'repair_code', r.repair_code,
        'device_model', r.device_model,
        'problem', r.problem,
        'status', r.status,
        'received_date', r.received_date,
        'updated_at', r.updated_at,
        'estimated_delivery', r.estimated_delivery,
        'public_note', r.public_note,
        'delivered_on', r.delivered_on,
        'warranty_until', case
          when r.status = 'Delivered' and r.delivered_on is not null and coalesce(r.warranty_days, 0) > 0
          then r.delivered_on + r.warranty_days end,
        'history', (
          select coalesce(jsonb_agg(jsonb_build_object('status', h.status, 'changed_at', h.changed_at) order by h.changed_at), '[]'::jsonb)
          from public.repair_status_history h where h.repair_id = r.id
        )
      ) order by r.received_date desc, r.created_at desc
    ), '[]'::jsonb)
  ) into v_result
  from public.repairs r
  where r.customer_id = v_cust.id;

  return v_result;
end;
$function$;

revoke all on function public.track_repairs_v2(text, text) from public;
grant execute on function public.track_repairs_v2(text, text) to anon, authenticated;

-- Naya page live hone ke BAAD purana (sirf-number wala) function band karna hai:
-- revoke execute on function public.track_repairs(text) from anon, authenticated, public;
