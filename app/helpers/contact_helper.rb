module ContactHelper
  def self.address_for_pdf(contact)
    [
      [contact&.street, contact&.extended].reject(&:blank?).join(', '),
      [contact&.postal_code, contact&.city].reject(&:blank?).join(' '),
      'www.aoz.ch/freiwilligenarbeit'
    ].compact.join('<br>')
  end
end
