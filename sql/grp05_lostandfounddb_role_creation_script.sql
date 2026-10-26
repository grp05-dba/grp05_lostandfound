CREATE ROLE lostandfound_app WITH LOGIN PASSWORD 'dontshare123'

GRANT USAGE ON SCHEMA public TO lostandfound_app;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO lostandfound_app;