require 'securerandom'

module AlphanumericallyIdentifiable
  extend ActiveSupport::Concern

  def generate(attributes = {})
    attrs = attributes.merge(generate_attributes)
    new(attrs)
  end

  def generate!(attributes = {})
    attrs = attributes.merge(generate_attributes)
    create!(attrs)
  end

  def random_id
    SecureRandom.alphanumeric(10)
  end

  private

  def generate_attributes
    { id: random_id }
  end
end