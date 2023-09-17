CREATE TABLE contacts (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL,
  phone_number char(10) UNIQUE NOT NULL,
  email_address text UNIQUE NOT NULL
);