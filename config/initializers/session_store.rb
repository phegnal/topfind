# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_protdb-hobo1_session',
  :secret      => 'ff28f040d8f1d643603415b7c5461477a34e60811219f8e47c1d355adcdc9ebcba31429dd68de7e3ccf753f75f871bc6b5d0c7bc869d6db139a9f47664855b8e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
