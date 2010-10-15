# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_kde-ru_session',
  :secret      => 'fe2fe0fe899350d51e9a415ac2bd3a76a2e0976d9b1c72dc0aa43184bdda7c27833591e21523adfeda55c77e40c0a1f2fdf7326e2c931fa9088368de1aa102bd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
