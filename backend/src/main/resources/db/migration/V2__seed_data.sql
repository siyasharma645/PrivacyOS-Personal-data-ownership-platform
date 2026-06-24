
INSERT INTO users (id,email,password_hash,full_name,privacy_score,risk_level,email_verified,provider)
VALUES ('a0000000-0000-0000-0000-000000000001','demo@privacyos.io','$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4J/6LzxUlm','Alex Rivera',62,'MEDIUM',TRUE,'LOCAL');

INSERT INTO connected_accounts (id,user_id,provider,provider_user_id,provider_email,display_name,scopes,risk_contribution,status,last_synced_at) VALUES
('b0000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001','GOOGLE','g-123','alex@gmail.com','Alex Rivera (Google)',ARRAY['email','profile','https://www.googleapis.com/auth/gmail.readonly','https://www.googleapis.com/auth/contacts.readonly'],18,'ACTIVE',NOW()-INTERVAL '2 hours'),
('b0000000-0000-0000-0000-000000000002','a0000000-0000-0000-0000-000000000001','GITHUB','gh-789','alex@github.com','alexrivera',ARRAY['user','repo','read:org','notifications'],8,'ACTIVE',NOW()-INTERVAL '1 day'),
('b0000000-0000-0000-0000-000000000003','a0000000-0000-0000-0000-000000000001','LINKEDIN','li-abc','alex@linkedin.com','Alex Rivera',ARRAY['r_liteprofile','r_emailaddress','w_member_social'],5,'ACTIVE',NOW()-INTERVAL '3 days');

INSERT INTO permissions (account_id,scope_name,display_name,description,risk_level,category,data_types,is_revocable,is_sensitive) VALUES
('b0000000-0000-0000-0000-000000000001','https://www.googleapis.com/auth/gmail.readonly','Read Gmail','Can read all your email messages and settings','HIGH','COMMUNICATION',ARRAY['Emails','Contacts','Attachments'],TRUE,TRUE),
('b0000000-0000-0000-0000-000000000001','https://www.googleapis.com/auth/contacts.readonly','Read Contacts','Can read your Google Contacts','MEDIUM','PERSONAL_DATA',ARRAY['Names','Phone numbers','Addresses'],TRUE,FALSE),
('b0000000-0000-0000-0000-000000000001','email','Email Address','Access your email address','LOW','IDENTITY',ARRAY['Email'],FALSE,FALSE),
('b0000000-0000-0000-0000-000000000001','profile','Basic Profile','Access your basic profile info','LOW','IDENTITY',ARRAY['Name','Photo'],FALSE,FALSE),
('b0000000-0000-0000-0000-000000000002','repo','Repository Access','Full access to public and private repositories','HIGH','PROFESSIONAL',ARRAY['Code','Commits','Pull requests'],TRUE,TRUE),
('b0000000-0000-0000-0000-000000000002','read:org','Read Organizations','Read-only access to organization info','MEDIUM','PROFESSIONAL',ARRAY['Organization data','Team membership'],TRUE,FALSE),
('b0000000-0000-0000-0000-000000000002','notifications','Notifications','Access your notifications','LOW','BEHAVIORAL',ARRAY['Activity data'],TRUE,FALSE),
('b0000000-0000-0000-0000-000000000003','r_liteprofile','Basic LinkedIn Profile','Access your LinkedIn profile','LOW','IDENTITY',ARRAY['Name','Photo','Headline'],FALSE,FALSE),
('b0000000-0000-0000-0000-000000000003','w_member_social','Post on LinkedIn','Can post on your behalf','MEDIUM','BEHAVIORAL',ARRAY['Posts','Activity'],TRUE,FALSE);

INSERT INTO breach_records (user_id,breach_name,title,domain,breach_date,data_classes,pwn_count,description,is_verified) VALUES
('a0000000-0000-0000-0000-000000000001','LinkedIn','LinkedIn','linkedin.com','2021-06-22',ARRAY['Email addresses','Names','Scraped data'],700000000,'LinkedIn had 700M user records scraped and posted to a hacker forum in June 2021.',TRUE),
('a0000000-0000-0000-0000-000000000001','Adobe','Adobe','adobe.com','2013-10-04',ARRAY['Email addresses','Password hints','Usernames','Passwords'],152445165,'In October 2013, 153 million Adobe Records were breached with encrypted passwords.',TRUE);

INSERT INTO privacy_events (user_id,event_type,entity_type,title,description,severity,score_before,score_after) VALUES
('a0000000-0000-0000-0000-000000000001','ACCOUNT_CONNECTED','connected_account','Google Account Connected','Connected your Google account with 4 permissions','INFO',78,68),
('a0000000-0000-0000-0000-000000000001','BREACH_DETECTED','breach_record','Data Breach: LinkedIn','Your email was found in the LinkedIn 2021 data breach','CRITICAL',68,62),
('a0000000-0000-0000-0000-000000000001','PERMISSION_RISK','permission','High-Risk Permission Detected','Gmail read access grants broad email visibility','WARNING',62,62),
('a0000000-0000-0000-0000-000000000001','ACCOUNT_CONNECTED','connected_account','GitHub Account Connected','Connected your GitHub account with repository access','INFO',75,68);

INSERT INTO privacy_recommendations (user_id,type,priority,title,description,action_label,expected_score_improvement,related_account_id) VALUES
('a0000000-0000-0000-0000-000000000001','REVOKE_PERMISSION','HIGH','Revoke Gmail Read Access','The gmail.readonly scope grants broad access to all your emails. Consider revoking it if not actively needed.','Revoke Access',8,'b0000000-0000-0000-0000-000000000001'),
('a0000000-0000-0000-0000-000000000001','REMEDIATE_BREACH','CRITICAL','Resolve LinkedIn Breach','Your data was exposed in the LinkedIn breach. Change your password immediately.','Change Password',10,NULL),
('a0000000-0000-0000-0000-000000000001','REVIEW_PERMISSIONS','MEDIUM','Review GitHub Repo Access','Your GitHub token has full repository access. Consider a scoped token with minimal permissions.','Review Access',4,'b0000000-0000-0000-0000-000000000002');

INSERT INTO privacy_score_history (user_id,score,risk_level,recorded_at) VALUES
('a0000000-0000-0000-0000-000000000001',85,'LOW',NOW()-INTERVAL '30 days'),
('a0000000-0000-0000-0000-000000000001',78,'LOW',NOW()-INTERVAL '25 days'),
('a0000000-0000-0000-0000-000000000001',75,'LOW',NOW()-INTERVAL '20 days'),
('a0000000-0000-0000-0000-000000000001',72,'LOW',NOW()-INTERVAL '15 days'),
('a0000000-0000-0000-0000-000000000001',68,'MEDIUM',NOW()-INTERVAL '10 days'),
('a0000000-0000-0000-0000-000000000001',65,'MEDIUM',NOW()-INTERVAL '7 days'),
('a0000000-0000-0000-0000-000000000001',62,'MEDIUM',NOW()-INTERVAL '3 days'),
('a0000000-0000-0000-0000-000000000001',62,'MEDIUM',NOW());
