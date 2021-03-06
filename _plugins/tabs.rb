require 'singleton'

module Jekyll
  class TabsTag < Liquid::Block
    include Liquid::StandardFilters

    def initialize(tag, options, *args)
      super
      @id = TabSequencer.instance.get_identifier
      @code = options.include? "code" # This tab only contains a code block
    end

    def identifier(index, name)
      slug = name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '') # http://stackoverflow.com/questions/4308377/ruby-post-title-to-slug
      sprintf("tabs-%s-%s-%s", @id, index, slug)
    end

    def render(context)
      markup = super
      blocks = markup.split("~~").drop(1) # The first block starts with ~~, so drop everything before this first ~~.

      tabs = {}
      blocks.each do |section|
        section = section.split("\n")
        tabs[section.shift] = section.join("\n")
      end

      # { Ruby: "..", Rails: "" }
      titles = tabs.keys.collect.with_index do |tab, index|
        classes = ["tab-title"]
        classes << "active" if index == 0
        sprintf("<li class='%s'><a href='#%s'>%s</a></li>",
                classes.join(" "),
                identifier(index, tab),
                tab
        )
      end
      contents = tabs.collect.with_index do |(tab, content), index|
        classes = ["content"]
        classes << "active" if index == 0
        sprintf("<div class='%s' id='%s'>%s</div>",
                classes.join(" "),
                identifier(index, tab),
                Kramdown::Document.new(content).to_html
        )
      end

      sprintf("<div class='%s'><ul class='tabs' data-tab>%s</ul>\n<div class='tabs-content'>%s</div></div>\n",
                    @code ? "tabs-container code-only" : "tabs-container",
                    titles.join("\n"),
                    contents.join("\n")
      )
    end

    class TabSequencer
      include Singleton

      def initialize
        @sequence = 0
      end

      def get_identifier
        @sequence += 1
      end
    end
  end
end

Liquid::Template.register_tag('tabs', Jekyll::TabsTag)

