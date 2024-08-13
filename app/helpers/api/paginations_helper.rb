module Api::PaginationsHelper
  include Pagy::Backend

  def pagination_options
    limit = params[:limit].to_i
    items_per_page = limit.positive? ? limit : Settings.limit.limit_10

    current_page = if params[:page].to_i.positive?
                     params[:page].to_i
                   else
                     Settings.page_default
                   end
    {
      limit: items_per_page,
      page: current_page
    }
  end

  def pagy_metadata pagy
    {
      total_items: pagy.count,
      current_page: pagy.page,
      limit: pagy.limit,
      total_pages: pagy.last
    }
  end
end
