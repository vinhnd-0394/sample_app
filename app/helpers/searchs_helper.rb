module SearchsHelper
  def fill_params_value key_search
    params.dig(:q, key_search).presence
  end
end
