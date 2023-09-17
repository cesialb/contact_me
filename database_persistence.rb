# frozen_string_literal: true

require 'pg'
require 'pry'

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: 'contacts')
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def all_contacts
    sql = 'SELECT id, name FROM contacts ORDER BY name'
    result = query(sql)

    result.map do |tuple|
      { id: tuple['id'].to_i, name: tuple['name'] }
    end
  end

  def find_contact(id)
    sql = 'SELECT * FROM contacts WHERE id = $1'
    result = query(sql, id)

    tuple_to_contact_hash(result.first)
  end

  def contact?(id)
    sql = 'SELECT id FROM contacts'
    result = query(sql)
    result.values.flatten.include?(id.to_s)
  end

  def create_new_user(info)
    sql = <<~SQL
      INSERT INTO contacts (name, phone_number, email_address)
      VALUES ($1, $2, $3)
    SQL

    query(sql, info[0], info[1], info[2])
  end

  def update_contact(id, info)
    sql = <<~SQL
      UPDATE contacts
      SET name = $1, phone_number = $2, email_address = $3
      WHERE id = $4
    SQL

    query(sql, info[0], info[1], info[2], id)
  end

  def delete_contact(id)
    sql = <<~SQL
      DELETE FROM contacts
      WHERE id = $1
    SQL

    query(sql, id)
  end

  def duplicate_contact?(name)
    sql = 'SELECT name FROM contacts'
    result = query(sql)

    result.values.flatten.include?(name)
  end

  private

  def tuple_to_contact_hash(tuple)
    { id: tuple['id'].to_i,
      name: tuple['name'],
      phone_number: tuple['phone_number'],
      email_address: tuple['email_address'] }
  end
end
