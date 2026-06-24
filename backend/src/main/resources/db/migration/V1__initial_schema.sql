
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    full_name VARCHAR(255),
    avatar_url TEXT,
    email_verified BOOLEAN DEFAULT FALSE,
    privacy_score INTEGER DEFAULT 50 CHECK (privacy_score >= 0 AND privacy_score <= 100),
    risk_level VARCHAR(20) DEFAULT 'MEDIUM' CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    provider VARCHAR(50) DEFAULT 'LOCAL',
    provider_id VARCHAR(255),
    role VARCHAR(20) DEFAULT 'USER',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE connected_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email VARCHAR(255),
    display_name VARCHAR(255),
    avatar_url TEXT,
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMPTZ,
    scopes TEXT[],
    risk_contribution INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    last_synced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, provider, provider_user_id)
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES connected_accounts(id) ON DELETE CASCADE,
    scope_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    description TEXT,
    risk_level VARCHAR(20) DEFAULT 'LOW' CHECK (risk_level IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    category VARCHAR(100),
    data_types TEXT[],
    is_revocable BOOLEAN DEFAULT TRUE,
    is_sensitive BOOLEAN DEFAULT FALSE,
    granted_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE privacy_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    entity_type VARCHAR(50),
    title VARCHAR(255),
    description TEXT,
    payload JSONB,
    severity VARCHAR(20) DEFAULT 'INFO' CHECK (severity IN ('INFO','WARNING','CRITICAL')),
    score_before INTEGER,
    score_after INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE breach_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    breach_name VARCHAR(255) NOT NULL,
    title VARCHAR(255),
    domain VARCHAR(255),
    breach_date DATE,
    added_date DATE,
    data_classes TEXT[],
    pwn_count BIGINT,
    description TEXT,
    logo_path TEXT,
    is_verified BOOLEAN DEFAULT TRUE,
    is_sensitive BOOLEAN DEFAULT FALSE,
    is_fabricated BOOLEAN DEFAULT FALSE,
    is_retired BOOLEAN DEFAULT FALSE,
    is_spam_list BOOLEAN DEFAULT FALSE,
    remediated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, breach_name)
);

CREATE TABLE privacy_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL,
    priority VARCHAR(20) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW','MEDIUM','HIGH','CRITICAL')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    action_label VARCHAR(100),
    action_url TEXT,
    expected_score_improvement INTEGER DEFAULT 0,
    related_account_id UUID REFERENCES connected_accounts(id),
    related_permission_id UUID REFERENCES permissions(id),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING','COMPLETED','DISMISSED')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE TABLE privacy_score_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    risk_level VARCHAR(20),
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_accounts_user ON connected_accounts(user_id);
CREATE INDEX idx_permissions_account ON permissions(account_id);
CREATE INDEX idx_events_user ON privacy_events(user_id);
CREATE INDEX idx_events_created ON privacy_events(created_at DESC);
CREATE INDEX idx_breaches_user ON breach_records(user_id);
CREATE INDEX idx_recs_user ON privacy_recommendations(user_id);
CREATE INDEX idx_score_hist_user ON privacy_score_history(user_id);
CREATE INDEX idx_refresh_token ON refresh_tokens(token);

CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at=NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
CREATE TRIGGER trg_users_ua BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_accounts_ua BEFORE UPDATE ON connected_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
