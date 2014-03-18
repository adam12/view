class HelloWorldView
  include Lotus::View
end

class RenderView
  include Lotus::View
end

class JsonRenderView
  include Lotus::View
  format :json
end

class AppView
  include Lotus::View
  root __dir__ + '/fixtures/templates/app'
  layout :application
end

class AppViewLayout < AppView
  layout nil
end

class MissingTemplateView
  include Lotus::View
end

module App
  class View
    include Lotus::View
  end
end

class ApplicationLayout
  include Lotus::Layout

  def title
    'Title:'
  end
end

class GlobalLayout
end

module Articles
  class Index
    include Lotus::View
    layout :application

    def title
      "#{ layout.title } articles"
    end
  end

  class RssIndex < Index
    format :rss
    layout nil
  end

  class AtomIndex < RssIndex
    format :atom
    layout nil
  end

  class New
    include Lotus::View

    def errors
      {}
    end
  end

  class AlternativeNew
    include Lotus::View
  end

  class Create
    include Lotus::View
    template 'articles/new'

    def errors
      {title: 'Title is required'}
    end
  end

  class Show
    include Lotus::View

    def title
      @title ||= article.title.upcase
    end
  end

  class JsonShow < Show
    format :json

    def article
      OpenStruct.new(title: locals[:article].title.reverse)
    end

    def title
      super.downcase
    end
  end
end

class Map
  attr_reader :locations

  def initialize(locations)
    @locations = locations
  end

  def location_names
    @locations.join(', ')
  end
end

class MapPresenter
  include Lotus::Presenter

  def count
    locations.count
  end

  def location_names
    super.upcase
  end

  def inspect_object
    @object.inspect
  end
end

module Dashboard
  class Index
    include Lotus::View

    def map
      MapPresenter.new(locals[:map])
    end
  end
end

class IndexView
  include Lotus::View
  layout :application
end
