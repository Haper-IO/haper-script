CREATE EXTENSION IF NOT EXISTS vector;

-- CREATE TYPE proxy_status_enum AS ENUM ('active', 'inactive');
-- CREATE TYPE oauth_provider_enum AS ENUM ('google');

CREATE OR REPLACE FUNCTION update_time()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_time IS 'Trigger function to automatically update the updated_at column with the current timestamp when a row is modified';

CREATE TABLE IF NOT EXISTS users (
    user_id UUID NOT NULL,
    name VARCHAR(32),
    image TEXT,
    email VARCHAR(256) NOT NULL UNIQUE,
    email_verified BOOLEAN DEFAULT FALSE,
    password VARCHAR(128),
    stripe_customer_id VARCHAR(128),
    is_whitelisted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(user_id)
);

CREATE TRIGGER update_time_of_users
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_time();

-- CREATE TRIGGER update_time_of_users
-- BEFORE UPDATE ON users
-- FOR EACH ROW
-- EXECUTE FUNCTION update_time();

COMMENT ON TABLE users IS 'Users table, each record corrsponding to one unique user';

COMMENT ON COLUMN users.id IS 'Primary key of the users table';
COMMENT ON COLUMN users.name IS 'The name of the user';
COMMENT ON COLUMN users.image IS 'The portrait url of the the user';
COMMENT ON COLUMN users.email IS 'The email address of the user, must be unique';
COMMENT ON COLUMN users.email_verified IS 'Whether the email of user is verfied or not when user registerd by email';
COMMENT ON COLUMN users.password IS 'Hashed password of user';
COMMENT ON COLUMN users.stripe_customer_id IS 'Current user corresponding stripe customer id';
COMMENT ON COLUMN users.created_at IS 'UTC timestamp of when the user was created';
COMMENT ON COLUMN users.deleted_at IS 'UTC timestamp when the user was deleted';
COMMENT ON COLUMN users.updated_at IS 'UTC timestamp of when the user was updated';

CREATE TABLE IF NOT EXISTS accounts (
    account_id UUID NOT NULL,
    user_id UUID NOT NULL,
    provider VARCHAR(16) NOT NULL,
    provider_account_id TEXT NOT NULL,
    email VARCHAR(256),
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    expires_at BIGINT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (account_id),
    CONSTRAINT unique_provider_account UNIQUE (provider, provider_account_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TRIGGER update_time_of_accounts
BEFORE UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION update_time();

COMMENT ON TABLE accounts IS 'User OAuth accounts, one user can have multiple accounts';

COMMENT ON COLUMN accounts.id IS 'Record id of accounts table';
COMMENT ON COLUMN accounts.user_id IS 'References the users table id field';
COMMENT ON COLUMN accounts.provider IS 'The OAuth provider, like google, discord, etc.';
COMMENT ON COLUMN accounts.provider_account_id IS 'The unique account ID of the user for the provider';
COMMENT ON COLUMN accounts.email IS 'The email info returned by the provider, may vary for different providers';
COMMENT ON COLUMN accounts.access_token IS 'The access token returned by the provider';
COMMENT ON COLUMN accounts.refresh_token IS 'The refresh token returned by the provider, not all providers provide refresh tokens';
COMMENT ON COLUMN accounts.expires_at IS 'The unix timestamp of when the access token will expire';
COMMENT ON COLUMN accounts.created_at IS 'UTC timestamp when the account was created';
COMMENT ON COLUMN accounts.updated_at IS 'UTC timestamp when the account was last updated';


CREATE TABLE IF NOT EXISTS user_settings (
    user_id UUID NOT NULL,
    key_message_tags VARCHAR(32)[],
    report_max_duration INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(user_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TRIGGER update_time_of_user_settings
BEFORE UPDATE ON user_settings
FOR EACH ROW
EXECUTE FUNCTION update_time();

COMMENT ON TABLE user_settings IS 'User general preference and setting info';

COMMENT ON COLUMN user_settings.user_id IS 'References the users table id field';
COMMENT ON COLUMN user_settings.key_message_tags IS 'The message tags that the user consider are important';
COMMENT ON COLUMN user_settings.report_max_duration IS 'Maximum time duration for a report cover in seconds';
COMMENT ON COLUMN user_settings.created_at IS 'UTC timestamp when the setting record was first created';
COMMENT ON COLUMN user_settings.updated_at IS 'UTC timestamp of the last update to the setting record';

-- CREATE TYPE message_tracking_status_enum AS ENUM ('not_started', 'ongoing', 'stopped', 'error');
CREATE TABLE IF NOT EXISTS message_tracking_records (
    user_id UUID NOT NULL,
    account_id UUID NOT NULL,
    account_provider VARCHAR(16) NOT NULL,
    status VARCHAR(16) NOT NULL,
    error_info TEXT,
    extra_info JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (user_id, account_id)
);

CREATE TRIGGER update_time_of_message_tracking_records
BEFORE UPDATE ON message_tracking_records
FOR EACH ROW
EXECUTE FUNCTION update_time();

COMMENT ON TABLE message_tracking_records IS 'Message tracking status of on perticular user';

COMMENT ON COLUMN message_tracking_records.user_id IS 'References the users table id field';
COMMENT ON COLUMN message_tracking_records.account_id IS 'References the accounts table id field';
COMMENT ON COLUMN message_tracking_records.status IS 'The status of the message tracking record';
COMMENT ON COLUMN message_tracking_records.error_info IS 'The error information if the status is error';
COMMENT ON COLUMN message_tracking_records.extra_info IS 'The extra information about message tracking, normally related to provider specific information';
COMMENT ON COLUMN message_tracking_records.created_at IS 'UTC timestamp when the message tracking record was first created';
COMMENT ON COLUMN message_tracking_records.updated_at IS 'UTC timestamp of the last update to the message tracking record';

CREATE TABLE IF NOT EXISTS preset_message_tags (
    id SMALLSERIAL NOT NULL,
    tag VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id)
);

CREATE TRIGGER update_time_of_preset_message_tags
BEFORE UPDATE ON preset_message_tags
FOR EACH ROW
EXECUTE FUNCTION update_time();

COMMENT ON TABLE preset_message_tags IS 'System preset message tags';

COMMENT ON COLUMN preset_message_tags.id IS 'Autoincrement id number';
COMMENT ON COLUMN preset_message_tags.tag IS 'The tag name';
COMMENT ON COLUMN preset_message_tags.created_at IS 'UTC timestamp when the tag record was first created';
COMMENT ON COLUMN preset_message_tags.updated_at IS 'UTC timestamp of the last update to the tag record';

-- CREATE TYPE categories_enum AS ENUM ('essential', 'non-essential')
-- CREATE TYPE action_enum AS ENUM ('change category', 'delete', 'reply')

-- COMMENT ON TYPE categories_enum IS 'Defines the categories for emails: essential or non-essential';
-- COMMENT ON TYPE action_enum IS 'Defines possible user actions on emails, such as change category, delete, or reply';


CREATE TABLE IF NOT EXISTS emails (
    id BIGSERIAL NOT NULL,
    user_id UUID NOT NULL,
    source VARCHAR(16) NOT NULL,
    message_id VARCHAR(256) NOT NULL,
    thread_id VARCHAR(256),
    sender VARCHAR(320) NOT NULL,
    receiver TEXT NOT NULL,
    subject TEXT,
    receive_at TIMESTAMPTZ NOT NULL,
    tags TEXT[],
    summary TEXT NOT NULL,
    summary_embedding VECTOR(768),
    llm_category VARCHAR(16) NOT NULL,
    modified_category VARCHAR(16),
    llm_action VARCHAR(16) NOT NULL,
    modified_action VARCHAR(16),
    reply_message TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TRIGGER update_time_of_emails
BEFORE UPDATE ON emails
FOR EACH ROW
EXECUTE FUNCTION update_time();

COMMENT ON TABLE emails IS 'Stores metadata and content of emails fetched from OAuth providers, along with user actions and LLM proceesed data';

COMMENT ON COLUMN emails.id IS 'Record id for the email table';
COMMENT ON COLUMN emails.user_id IS 'References the users id field';
COMMENT ON COLUMN emails.source IS 'The email source like gmail and outlook';
COMMENT ON COLUMN emails.message_id IS 'Unique identifier for the email from the message source';
COMMENT ON COLUMN emails.thread_id IS 'Identifier for the email thread (if applicable)';
COMMENT ON COLUMN emails.sender IS 'Name and email address of the sender';
COMMENT ON COLUMN emails.sender IS 'Email address of the receiver';
COMMENT ON COLUMN emails.subject IS 'Subject line of the email';
COMMENT ON COLUMN emails.receive_at IS 'Timestamp when the email was received';
COMMENT ON COLUMN emails.tags IS 'Array of tags assigned to the email';
COMMENT ON COLUMN emails.summary IS 'Summary of the email content provided by the LLM';
COMMENT ON COLUMN emails.summary_embedding IS 'Summary embedding value of email content of LLM embedding model';
COMMENT ON COLUMN emails.llm_category IS 'Category of the email provided by the LLM';
COMMENT ON COLUMN emails.modified_category IS 'Modified category of the email by user';
COMMENT ON COLUMN emails.llm_action IS 'Action suggested by the LLM for the email';
COMMENT ON COLUMN emails.modified_action IS 'Modified action taken by the user on the email';
COMMENT ON COLUMN emails.reply_message IS 'Reply message of the email';
COMMENT ON COLUMN emails.created_at IS 'Timestamp when the email record was created';
COMMENT ON COLUMN emails.Deleted_at IS 'Timestamp when the email record was deleted';
COMMENT ON COLUMN emails.updated_at IS 'Timestamp when the email record was last updated';

CREATE TABLE IF NOT EXISTS reports (
    id UUID NOT NULL,
    user_id UUID NOT NULL,
    type VARCHAR(16) NOT NULL,
    status VARCHAR(16) NOT NULL,
    content JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    finalized_at TIMESTAMPTZ,
    last_access_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TRIGGER update_time_of_reports
BEFORE UPDATE ON reports
FOR EACH ROW
EXECUTE FUNCTION update_time();

COMMENT ON TABLE reports IS 'Message report';

COMMENT ON COLUMN reports.id IS 'Unique identifier for the report';
COMMENT ON COLUMN reports.user_id IS 'References the user (from users table) who generated the report';
COMMENT ON COLUMN reports.type IS 'Report type, like Realtime, and Previous';
COMMENT ON COLUMN reports.status IS 'The status of the report';
COMMENT ON COLUMN reports.content IS 'JSONB content of the report, storing structured data';
COMMENT ON COLUMN reports.created_at IS 'Timestamp when the report was created';
COMMENT ON COLUMN reports.finalized_at IS 'When is report is finalized';
COMMENT ON COLUMN reports.last_access_at IS 'Timestamp when the report was created';
COMMENT ON COLUMN reports.deleted_at IS 'Timestamp when the report is marked as deleted by the user';
COMMENT ON COLUMN reports.updated_at IS 'Timestamp when the report was last updated';

CREATE TABLE IF NOT EXISTS report_batch_actions (
    id UUID NOT NULL,
    report_id UUID NOT NULL,
    status VARCHAR(16) NOT NULL,
    total_actions INTEGER NOT NULL,
    succeed_actions INTEGER NOT NULL DEFAULT 0,
    failed_actions INTEGER NOT NULL DEFAULT 0,
    logs JSONB[],
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY(report_id) REFERENCES reports(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TRIGGER update_time_of_report_batch_actions
BEFORE UPDATE ON report_batch_actions
FOR EACH ROW
EXECUTE FUNCTION update_time();

COMMENT ON TABLE report_batch_actions IS 'report action running logs';

COMMENT ON COLUMN report_batch_actions.id IS 'Unique run id';
COMMENT ON COLUMN report_batch_actions.report_id IS 'References the reports table id field';
COMMENT ON COLUMN report_batch_actions.status IS 'Status of the batch action run';
COMMENT ON COLUMN report_batch_actions.total_actions IS 'Total number of actions to run';
COMMENT ON COLUMN report_batch_actions.succeed_actions IS 'Total number of successful actions';
COMMENT ON COLUMN report_batch_actions.failed_actions IS 'Total number of failed actions';
COMMENT ON COLUMN report_batch_actions.logs IS 'Report batch action logs list';
COMMENT ON COLUMN report_batch_actions.created_at IS 'Timestamp when the batch action was created';
COMMENT ON COLUMN report_batch_actions.updated_at IS 'Timestamp when the batch action was last updated';

CREATE TABLE IF NOT EXISTS user_subscriptions (
    user_id UUID NOT NULL,
    stripe_customer_id VARCHAR(128) NOT NULL,
    stripe_subscription_id VARCHAR(128) NOT NULL,
    subscription_cycle VARCHAR(16) NOT NULL,
    subscription_status VARCHAR(16) NOT NULL,
    trial_end_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TRIGGER update_user_subscriptions
BEFORE UPDATE ON user_subscriptions
FOR EACH ROW
EXECUTE FUNCTION update_time();


COMMENT ON TABLE user_subscriptions IS 'User payment subscriptions';

COMMENT ON COLUMN user_subscriptions.user_id IS 'References the users table id field';
COMMENT ON COLUMN user_subscriptions.stripe_customer_id IS 'Stripe customer id of current user';
COMMENT ON COLUMN user_subscriptions.stripe_subscription_id IS 'Stripe customer id of current user';
COMMENT ON COLUMN user_subscriptions.subscription_cycle IS 'Payment subscription payment cycle';
COMMENT ON COLUMN user_subscriptions.subscription_status IS 'Payment subscription status';
COMMENT ON COLUMN user_subscriptions.trial_end_at IS 'Timestamp when the trail will end';
COMMENT ON COLUMN user_subscriptions.created_at IS 'Timestamp when the batch action was created';
COMMENT ON COLUMN user_subscriptions.updated_at IS 'Timestamp when the batch action was last updated';
