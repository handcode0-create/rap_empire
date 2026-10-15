-- RAP EMPIRE · schéma initial (provisoire, à valider avec D-09 : hors ligne + synchronisation)
-- Principe : sauvegarde = un document JSON versionné par joueur ; catalogue d'artistes = lecture seule.

create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  stage_name text not null default 'Djo Kéné',
  created_at timestamptz not null default now()
);

create table public.saves (
  user_id uuid not null references auth.users(id) on delete cascade,
  slot text not null default 'current' check (slot in ('current','previous')),
  schema_version int not null,
  state jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, slot)
);

-- Catalogue de démonstration (1 000 artistes fictifs) : données de référence, jamais modifiées par le client.
create table public.labels (code text primary key, nom text not null, siege text, data jsonb not null default '{}');
create table public.artists (id text primary key, nom text not null unique, rang_global int not null, label_code text references public.labels(code), data jsonb not null);
create index on public.artists (rang_global);

-- Conserve l'ancienne sauvegarde avant écrasement (exigence D-09 n°4).
create or replace function public.keep_previous_save() returns trigger language plpgsql security definer as $$
begin
  if old.slot = 'current' then
    insert into public.saves(user_id, slot, schema_version, state, updated_at)
    values (old.user_id, 'previous', old.schema_version, old.state, old.updated_at)
    on conflict (user_id, slot) do update set schema_version = excluded.schema_version, state = excluded.state, updated_at = excluded.updated_at;
  end if;
  new.updated_at = now();
  return new;
end $$;
create trigger saves_keep_previous before update on public.saves for each row execute function public.keep_previous_save();

alter table public.profiles enable row level security;
alter table public.saves enable row level security;
alter table public.labels enable row level security;
alter table public.artists enable row level security;

create policy "profil : le joueur lit et modifie le sien" on public.profiles for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "sauvegarde : le joueur gère la sienne" on public.saves for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "catalogue : lecture pour tous les connectés" on public.labels for select to authenticated using (true);
create policy "catalogue artistes : lecture pour tous les connectés" on public.artists for select to authenticated using (true);
