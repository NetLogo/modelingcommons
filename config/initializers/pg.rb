if defined? PGconn
  def PGconn.quote_ident(name)
    %("#{name}")
  end
end
