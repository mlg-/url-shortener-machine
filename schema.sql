DROP TABLE IF EXISTS urls;

CREATE TABLE urls(
  id SERIAL PRIMARY KEY,
  long_url VARCHAR(500) NOT NULL,
  short_url VARCHAR(255) NOT NULL
);