# frozen_string_literal: true

require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'sinatra/reloader'
require_relative 'database_persistence'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, escape_html: true
  also_reload 'database_persistence.rb'
end

before do
  @storage = DatabasePersistence.new(logger)
end

def load_contact(id)
  if error_for_contact_id(id)
    session[:error] = 'The contact id could not be found.'
    redirect '/contacts'
  end

  contact = @storage.find_contact(id)
  return contact if contact

  redirect '/contacts'
end

def error_for_contact_name(name)
  @storage.duplicate_contact?(name)
end

def error_for_contact_id(id)
  !@storage.contact?(id)
end

get '/' do
  redirect '/contacts'
end

# view list of contacts
get '/contacts' do
  @contacts = @storage.all_contacts
  erb :contacts, layout: :layout
end

# add new contact to list
get '/contacts/new' do
  erb :new_contact, layout: :layout
end

# create new contact
post '/contacts' do
  if error_for_contact_name(params[:name])
    session[:error] = 'There is already a contact with that name.'
    redirect '/contacts/new'
  else
    info = []
    info << params[:name]
    info << params[:phone_number]
    info << params[:email_address]

    @storage.create_new_user(info)
    session[:success] = 'The new contact has been created.'
    redirect '/contacts'
  end
end

# view a single contact
get '/contacts/:id' do
  @contact = load_contact(params[:id].to_i)
  erb :contact, layout: :layout
end

# editing existing contact
get '/contacts/:id/edit' do
  id = params[:id].to_i
  @contact = load_contact(id)
  erb :edit_contact, layout: :layout
end

# updating existing contact
post '/contacts/:id' do
  id = params[:id].to_i
  info = []
  info << params[:name]
  info << params[:phone_number]
  info << params[:email_address]

  @storage.update_contact(id, info)
  session[:success] = 'The contact has been updated.'
  redirect '/contacts'
end

post '/contacts/:id/destroy' do
  id = params[:id].to_i
  @storage.delete_contact(id)

  session[:success] = 'The contact has been deleted.'
  redirect '/contacts'
end
