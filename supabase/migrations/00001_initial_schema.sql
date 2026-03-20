-- LearingLeague Initial Schema
-- Supabase (PostgreSQL + PostGIS)

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- USERS (extends Supabase auth.users)
-- ============================================================
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  xp INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 1,
  streak_days INTEGER NOT NULL DEFAULT 0,
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- PROVIDERS (the megabase — fraud leads)
-- ============================================================
CREATE TYPE provider_category AS ENUM (
  'hospice',
  'childcare',
  'autism_center',
  'home_health',
  'nursing_home',
  'substance_abuse',
  'group_home',
  'other'
);

CREATE TABLE public.providers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  category provider_category NOT NULL,
  address TEXT,
  city TEXT,
  state CHAR(2) NOT NULL,
  zip TEXT,
  county TEXT,
  location GEOGRAPHY(POINT, 4326),
  phone TEXT,
  license_number TEXT,
  license_status TEXT,
  funding_source TEXT,
  funding_amount NUMERIC,
  owner_name TEXT,
  registered_agent TEXT,
  registration_date DATE,
  fraud_score INTEGER DEFAULT 0 CHECK (fraud_score >= 0 AND fraud_score <= 100),
  fraud_factors JSONB DEFAULT '[]'::jsonb,
  source_name TEXT NOT NULL,
  source_url TEXT,
  source_retrieved_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_user_submitted BOOLEAN NOT NULL DEFAULT FALSE,
  submitted_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_providers_state ON public.providers(state);
CREATE INDEX idx_providers_category ON public.providers(category);
CREATE INDEX idx_providers_fraud_score ON public.providers(fraud_score DESC);
CREATE INDEX idx_providers_location ON public.providers USING GIST(location);
CREATE INDEX idx_providers_zip ON public.providers(zip);

-- ============================================================
-- ROUTES (claimable investigation territories)
-- ============================================================
CREATE TABLE public.routes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  state CHAR(2) NOT NULL,
  region TEXT,
  zip_codes TEXT[],
  bounds JSONB,
  provider_count INTEGER NOT NULL DEFAULT 0,
  active_claimants INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_routes_state ON public.routes(state);

-- ============================================================
-- ROUTE CLAIMS (many-to-many: users <-> routes)
-- ============================================================
CREATE TYPE claim_status AS ENUM ('active', 'paused', 'completed', 'abandoned');

CREATE TABLE public.route_claims (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  route_id UUID NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status claim_status NOT NULL DEFAULT 'active',
  claimed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(route_id, user_id)
);

CREATE INDEX idx_route_claims_route ON public.route_claims(route_id);
CREATE INDEX idx_route_claims_user ON public.route_claims(user_id);

-- ============================================================
-- INVESTIGATIONS (evidence per provider per user)
-- ============================================================
CREATE TYPE investigation_status AS ENUM (
  'not_investigated',
  'red_flag',
  'seems_legit',
  'inconclusive'
);

CREATE TABLE public.investigations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  route_id UUID REFERENCES public.routes(id) ON DELETE SET NULL,
  status investigation_status NOT NULL DEFAULT 'not_investigated',
  notes TEXT,
  checklist JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_investigations_provider ON public.investigations(provider_id);
CREATE INDEX idx_investigations_user ON public.investigations(user_id);

-- ============================================================
-- EVIDENCE (photos, videos, documents per investigation)
-- ============================================================
CREATE TYPE evidence_type AS ENUM ('photo', 'video', 'document', 'note');

CREATE TABLE public.evidence (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  investigation_id UUID NOT NULL REFERENCES public.investigations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type evidence_type NOT NULL,
  file_url TEXT,
  thumbnail_url TEXT,
  caption TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  captured_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_evidence_investigation ON public.evidence(investigation_id);

-- ============================================================
-- REPORTS (submitted to government agencies)
-- ============================================================
CREATE TYPE report_status AS ENUM (
  'draft',
  'submitted',
  'acknowledged',
  'under_review',
  'action_taken',
  'closed'
);

CREATE TYPE report_agency AS ENUM (
  'hhs_oig',
  'doj_fca',
  'state_ag',
  'state_licensing',
  'other'
);

CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  investigation_id UUID NOT NULL REFERENCES public.investigations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  agency report_agency NOT NULL,
  agency_name TEXT,
  status report_status NOT NULL DEFAULT 'draft',
  reference_number TEXT,
  submitted_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reports_user ON public.reports(user_id);

-- ============================================================
-- PROVIDER CHANGE LOG (transparency / source tracking)
-- ============================================================
CREATE TABLE public.provider_changes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID NOT NULL REFERENCES public.providers(id) ON DELETE CASCADE,
  changed_by UUID REFERENCES public.profiles(id),
  change_type TEXT NOT NULL,
  old_values JSONB,
  new_values JSONB,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_provider_changes_provider ON public.provider_changes(provider_id);

-- ============================================================
-- LEADERBOARD SNAPSHOTS
-- ============================================================
CREATE TABLE public.leaderboard_snapshots (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  scope TEXT NOT NULL DEFAULT 'national',
  scope_value TEXT,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  xp INTEGER NOT NULL,
  rank INTEGER NOT NULL,
  snapshot_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leaderboard_scope ON public.leaderboard_snapshots(scope, scope_value, snapshot_at DESC);

-- ============================================================
-- XP EVENTS (audit trail for points)
-- ============================================================
CREATE TABLE public.xp_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  xp_amount INTEGER NOT NULL,
  reference_id UUID,
  reference_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_xp_events_user ON public.xp_events(user_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.route_claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investigations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.provider_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leaderboard_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_events ENABLE ROW LEVEL SECURITY;

-- Profiles: public read, own write
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Providers: public read, authenticated write for submissions
CREATE POLICY "Providers are viewable by everyone" ON public.providers FOR SELECT USING (true);
CREATE POLICY "Authenticated users can submit providers" ON public.providers FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Routes: public read
CREATE POLICY "Routes are viewable by everyone" ON public.routes FOR SELECT USING (true);

-- Route claims: public read, own write
CREATE POLICY "Route claims are viewable by everyone" ON public.route_claims FOR SELECT USING (true);
CREATE POLICY "Users can claim routes" ON public.route_claims FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own claims" ON public.route_claims FOR UPDATE USING (auth.uid() = user_id);

-- Investigations: public read, own write
CREATE POLICY "Investigations are viewable by everyone" ON public.investigations FOR SELECT USING (true);
CREATE POLICY "Users can create investigations" ON public.investigations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own investigations" ON public.investigations FOR UPDATE USING (auth.uid() = user_id);

-- Evidence: public read, own write
CREATE POLICY "Evidence is viewable by everyone" ON public.evidence FOR SELECT USING (true);
CREATE POLICY "Users can upload evidence" ON public.evidence FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Reports: own only
CREATE POLICY "Users can view own reports" ON public.reports FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create reports" ON public.reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reports" ON public.reports FOR UPDATE USING (auth.uid() = user_id);

-- Provider changes: public read
CREATE POLICY "Provider changes are viewable by everyone" ON public.provider_changes FOR SELECT USING (true);
CREATE POLICY "Authenticated users can log changes" ON public.provider_changes FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Leaderboard: public read
CREATE POLICY "Leaderboard is viewable by everyone" ON public.leaderboard_snapshots FOR SELECT USING (true);

-- XP events: own read
CREATE POLICY "Users can view own XP events" ON public.xp_events FOR SELECT USING (auth.uid() = user_id);

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_providers_updated_at BEFORE UPDATE ON public.providers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_routes_updated_at BEFORE UPDATE ON public.routes FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_route_claims_updated_at BEFORE UPDATE ON public.route_claims FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_investigations_updated_at BEFORE UPDATE ON public.investigations FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON public.reports FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Award XP and update profile
CREATE OR REPLACE FUNCTION award_xp(p_user_id UUID, p_action TEXT, p_amount INTEGER, p_ref_id UUID DEFAULT NULL, p_ref_type TEXT DEFAULT NULL)
RETURNS void AS $$
BEGIN
  INSERT INTO public.xp_events (user_id, action, xp_amount, reference_id, reference_type)
  VALUES (p_user_id, p_action, p_amount, p_ref_id, p_ref_type);

  UPDATE public.profiles
  SET xp = xp + p_amount,
      level = GREATEST(1, FLOOR(SQRT((xp + p_amount) / 100.0))::INTEGER)
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update route claimant count
CREATE OR REPLACE FUNCTION update_route_claimant_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.routes
  SET active_claimants = (
    SELECT COUNT(*) FROM public.route_claims
    WHERE route_id = COALESCE(NEW.route_id, OLD.route_id) AND status = 'active'
  )
  WHERE id = COALESCE(NEW.route_id, OLD.route_id);
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_claimant_count AFTER INSERT OR UPDATE OR DELETE ON public.route_claims FOR EACH ROW EXECUTE FUNCTION update_route_claimant_count();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, display_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || LEFT(NEW.id::TEXT, 8)), COALESCE(NEW.raw_user_meta_data->>'display_name', ''));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();
