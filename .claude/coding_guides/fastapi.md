# FastAPI with an SQL database

Follow the structure of FastAPI's tutorial "SQL (Relational) Databases" and
the official Full Stack FastAPI Template, also when the project uses
SQLAlchemy and pydantic separately instead of SQLModel:

- **Names:** the table class carries the entity's name (`Hero`); the API
  schemas carry a role suffix (`HeroCreate`, `HeroUpdate`, `HeroPublic`).
- **Layering:** code below the path operations works with table objects and
  returns them. The path operation declares the `…Public` schema as its
  `response_model`, and FastAPI turns the object into the response. Service
  or CRUD functions never return API schemas.
- **Session:** one session per request from a dependency; it stays open
  while FastAPI serializes the response.

Deviate only for a stated reason, recorded in the project's
docs/ARCHITECTURE.md.
