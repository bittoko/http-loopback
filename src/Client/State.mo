

module {

  public type State = { var http_gateway_url: Text };

  public func init(url: Text): State = { var http_gateway_url = url };

};