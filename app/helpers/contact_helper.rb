module ContactHelper
  def self.address_for_pdf(contact)
    [
      [contact&.street, contact&.extended].compact.join(', '), 
      [contact&.postal_code, contact&.city].compact.join(' '), 
      "www.aoz.ch/freiwilligenarbeit"
    ].compact.join('<br>')
  end
end
