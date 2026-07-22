# frozen_string_literal: true

# Reproduces #427: a column whose `source` points at an association name
# (`User.post`) rather than a real database column (the physical column is
# `post_id`). Building a WHERE against `users.post` raises at the database, so
# such a column must be treated as non-searchable and skipped when building
# search conditions.
class DatatableNonexistentColumn < ComplexDatatable
  def view_columns
    super.merge(
      post: { source: 'User.post' }
    )
  end
end
