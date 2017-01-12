@SeoInspector = do ->
  init: ->
    @inited ||= do =>
      @doc  = $ document
      @body = $ 'body'

      @render_css()
      @seo_inspector_button_render()
      @seo_inspector_button_init()

      @turbolinks_workaround()

  turbolinks_workaround: ->
    if Turbolinks?
      @doc.on 'page:fetch', =>
        @remove_seo_inspector()
        @remove_seo_inspector_button()

  seo_inspector_button_render: ->
    @body.append """
      <div class='seo-inspector--button'>SEO</div>
    """
  remove_seo_inspector_button: ->
    $('.seo-inspector--button').remove()

  seo_inspector_button_init: ->
    @body.on 'click', '.seo-inspector--button', (e) =>
      btn = $ e.currentTarget
      if btn.hasClass 'seo-inspector--on'
        btn.removeClass 'seo-inspector--on'
        @remove_seo_inspector()
      else
        btn.addClass 'seo-inspector--on'
        @render_seo_inspector()

  render_section: (title, text) ->
    unless text
      """
        <div class='seo-inspector--section'>
          <div class='seo-inspector--section-title'>
            #{ title }
            <span class='seo-inspector--not-found'>NOT FOUND</span>
          </div>
        </div>
      """
    else

      """
        <div class='seo-inspector--section'>
          <div class='seo-inspector--section-title'>
            #{ title }
          </div>

          <div class='seo-inspector--section-text'>
            <span class='seo-inspector--found'>
              #{ text }
            </span>
          </div>
        </div>
      """

  render_delimiter: ->
    """
      <div class='seo-inspector--delimiter'></div>
    """

  group_title: (title) ->
    """
      <div class='seo-inspector--group-title'>#{title}</div>
    """

  remove_seo_inspector: ->
    $('.seo-inspector').remove()

  render_seo_inspector: ->
    @remove_seo_inspector()
    delimiter = @render_delimiter()

    section_title       = @render_section( 'Page Title:',    @get_title() )
    section_keywords    = @render_section( 'Page KeyWords:', @get_keywords() )
    section_description = @render_section( 'Page Description:', @get_description() )
    section_author      = @render_section( 'Page Author:', @get_author() )

    section_h1 = @render_section( 'Header 1:', @get_h1() )
    section_h2 = @render_section( 'Header 2:', @get_h2() )
    section_h3 = @render_section( 'Header 3:', @get_h3() )

    section_b = @render_section( 'B, STRONG:', @get_b_strong() )
    section_i = @render_section( 'I, EM:', @get_em_i() )

    section_og_title  = @render_section( 'OG Title:', @get_og_title() )
    section_og_descr  = @render_section( 'OG Description:', @get_og_description() )
    section_og_image  = @render_section( 'OG Image:',  @get_og_image() )
    section_og_author = @render_section( 'OG Author:', @get_og_author() )

    section_og_site   = @render_section( 'OG Site name:', @get_og_site_name() )
    section_og_pub_at = @render_section( 'OG Published at:', @get_og_published_at() )
    section_og_mod_at = @render_section( 'OG Modified at:', @get_og_modified_at() )

    section_og_tags     = @render_section( 'OG Tags:', @get_og_tags() )
    section_og_sections = @render_section( 'OG Sections:', @get_og_sections() )

    section_og_article_author    = @render_section( 'OG Article Author:', @get_og_article_author() )
    section_og_article_publisher = @render_section( 'OG Article Publisher:', @get_og_article_publisher() )

    section_noindex = @render_section( 'NOINDEX:', @get_noindex() )
    section_check_links = @render_section( 'Important links:', @get_check_links() )

    @body.prepend """
      <div class='seo-inspector'>
        #{ section_title }
        #{ delimiter }
        #{ section_keywords }
        #{ delimiter }
        #{ section_description }
        #{ delimiter }
        #{ section_author }
        #{ delimiter }

        #{ section_h1 }
        #{ delimiter }
        #{ section_h2 }
        #{ delimiter }
        #{ section_h3 }
        #{ delimiter }

        #{ section_b }
        #{ delimiter }
        #{ section_i }
        #{ delimiter }

        #{ @group_title('OPEN GRAPH') }
        #{ delimiter }

        #{ section_og_site }
        #{ delimiter }
        #{ section_og_title }
        #{ delimiter }
        #{ section_og_descr }
        #{ delimiter }
        #{ section_og_image }
        #{ delimiter }
        #{ section_og_author }
        #{ delimiter }
        #{ section_og_sections }
        #{ delimiter }
        #{ section_og_tags }
        #{ delimiter }
        #{ section_og_article_author }
        #{ delimiter }
        #{ section_og_article_publisher }
        #{ delimiter }
        #{ section_og_pub_at }
        #{ delimiter }
        #{ section_og_mod_at }

        #{ @group_title('OTHER') }
        #{ section_noindex }
        #{ delimiter }
        #{ section_check_links }
      </div>
    """

  # HELPERS

  compact: (ary) -> ary.filter (i) -> i

  point_join: (ary) ->
    @compact(ary).join """
      <span class='seo-inspector--point'>•</span>
    """

  get_text: (ary) ->
    text = []
    for item in ary
      text.push $(item).text()
    text

  get_content_attr: (ary) ->
    text = []
    for item in ary
      text.push $(item).attr('content')
    text

  build_imgs: (urls) ->
    res = []
    for url in @compact(urls)
      res.push """
        <img src="#{url}" width='500'>
      """
    res.join('')

  # GET DATA

  get_title: ->
    $('title').text()

  get_keywords: ->
    $('[name=keywords]').attr('content')

  get_author: ->
    $('[name=author]').attr('content')

  get_description: ->
    $('[name=description]').attr('content')

  get_h1: ->
    ary = $('h1')
    text = @get_text(ary)
    @point_join(text)

  get_h2: ->
    ary = $('h2')
    text = @get_text(ary)
    @point_join(text)

  get_h3: ->
    ary = $('h3')
    text = @get_text(ary)
    @point_join(text)

  get_em_i: ->
    ary = $('em, i')
    text = @get_text(ary)
    @point_join(text)

  get_b_strong: ->
    ary = $('b, strong')
    text = @get_text(ary)
    @point_join(text)

  get_noindex: ->
    ary = $('noindex')
    text = @get_text(ary)
    @point_join(text)

  # OPEN GRAPH

  get_og_image: ->
    ary  = $('[property="og:image"]')
    urls = @get_content_attr(ary)
    @build_imgs(urls)

  get_og_title: ->
    $('[property="og:title"]').attr('content')

  get_og_description: ->
    $('[property="og:description"]').attr('content')

  get_og_site_name: ->
    $('[property="og:site_name"]').attr('content')

  get_og_published_at: ->
    $('[property="article:published_time"]').attr('content')

  get_og_modified_at: ->
    $('[property="article:modified_time"]').attr('content')

  get_og_author: ->
    $('[property="og:author"]').attr('content')

  get_og_tags: ->
    ary  = $('meta[property="article:tag"]')
    text = @get_content_attr(ary)
    @point_join(text)

  get_og_sections: ->
    ary  = $('meta[property="article:section"]')
    text = @get_content_attr(ary)
    @point_join(text)

  get_og_article_author: ->
    $('meta[property="article:author"]').attr('content')

  get_og_article_publisher: ->
    $('meta[property="article:publisher"]').attr('content')

  get_check_links: ->
    """
    <div class='seo-inspector--check-links'>
      <a href='http://vk.com/dev/pages.clearCache' target='_blank'>VK Cache reset</a>
      <a href='https://developers.facebook.com/tools/debug/og/object/' target='_blank'>Facebook debugger</a>
    </div>
    """

  render_css: ->
    @body.append """
      <style>
        .seo-inspector--block *{
          box-sizing: border-box;
          padding: 0; margin: 0;
          font-family: Arial;
          font-size: 10px;
        }
        .seo-inspector *::after,
        .seo-inspector *::before{
          box-sizing: border-box;
        }
        .seo-inspector{
          border: 7px solid orange;
        }
        .seo-inspector--section{
          padding: 15px;
        }
        .seo-inspector--section-title{
          font-size: 18px;
          font-weight: bold;
          margin-bottom: 15px;
        }
        .seo-inspector--section-text{
          font-size: 16px;
          line-height: 130%;
        }
        .seo-inspector--delimiter{
          border-bottom: 2px solid #eee;
        }
        .seo-inspector--not-found{
          color: red;
        }
        .seo-inspector--found{
          color: green;
        }
        .seo-inspector--group-title{
          padding: 15px;
          font-size:20px;
          font-weight: bold;
          background: lightblue;
        }
        .seo-inspector--button{
          padding: 10px 20px;
          position: fixed;
          top: 10px;
          right: 10px;
          cursor: pointer;
          background: orange;
          border-radius: 5px;
          font-size: 15px;
        }
        .seo-inspector--button.seo-inspector--on{
          background: lightgreen;
          color: white;
        }
        .seo-inspector--point{
          color: red;
          font-size: 20px;
          margin: 0 10px;
        }

        .seo-inspector--check-links a{
          color: red;
          margin-right: 30px;
        }
        .seo-inspector--check-links a:hover{
          color: blue;
        }
      </style>
    """