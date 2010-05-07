
require('aurita/plugin_controller')
require('aurita-gui/form')
Aurita.import_plugin_model :publish, :page_comment

module Aurita
module Plugins
module Publish

  class Page_Comment_Controller < Aurita::Plugin_Controller
    include Aurita::GUI

    def add
      super()
    end

    def delete
      super()
    end

    def list(params={})
    # {{{
      page = params[:instance]

      capt1 = rand(20)
      capt2 = rand(20)

      form = Form.new(:name     => :add_comment_form, 
                      :id       => :add_comment_form, 
                      :onsubmit => "Aurita.submit_form(this);") 
      form.add(Hidden_Field.new(:name  => :controller,
                                :value => 'Publish::Page_Comment'))
      form.add(Hidden_Field.new(:name  => :action, 
                                :value => :perform_add))
      form.add(Hidden_Field.new(:name  => :page_id, 
                                :value => page.page_id))
      form.add(Hidden_Field.new(:name  => :capt1, 
                                :value => capt1))
      form.add(Hidden_Field.new(:name  => :capt2, 
                                :value => capt2))
      
      form.add(Text_Field.new(:name  => :author_name, 
                              :label => tl(:comment_author_name)))
      form.add(Text_Field.new(:name  => :author_email, 
                              :label => tl(:comment_author_email)))
      form.add(Textarea_Field.new(:name => :comment, 
                                  :label => tl(:comment)))
      form.add(Text_Field.new(:name  => :capt, 
                              :id    => :capt, 
                              :label => " #{capt1} + #{capt2} = ?"))
      form[:capt].required!

      form[:author_email].required! 

      submit_button = HTML.div.form_buttons { 
        HTML.button(:onclick => "Aurita.submit_form('add_comment_form');") { 
          tl(:send_comment)
        }
      }

      HTML.div.page_comments { 
        HTML.h3.header { tl(:page_comments) } +
        HTML.div(:id => :add_comment_form_container) { 
          HTML.div { HTML.b { tl(:add_comment) } } + 
          form + submit_button 
        } +
        HTML.div.page_comment_list(:id => :page_comments) {
          comment_list(params)
        }
      }
    end # }}}

    def comment_list(params={})
    # {{{
      page   = params[:page]
      page ||= Page.get(param(:page_id))
      HTML.ul.page_comment_list {
        page.validated_comments.map { |c|
          HTML.li.page_comment { 
            HTML.div.author_name { c.author_name } + 
            HTML.div.date { datetime(c.timestamp_created) } + 
            HTML.div.comment { c.comment }
          }
        }
      }
    end # }}}

    def perform_add
    # {{{
      exec_js("$('capt').removeClassName('invalid');")
      exec_js("$('author_email').removeClassName('invalid');")

      failed = false
      capt = param(:capt1).to_i + param(:capt2).to_i
      if(param(:capt).to_s.squeeze(' ').to_i != capt) then
        exec_js("$('capt').addClassName('invalid');")
        failed = true
      end
      if(!param(:author_email).to_s.include?('@')) then
        exec_js("$('author_email').addClassName('invalid');")
        failed = true
      end
      
      if !failed then
        instance = super()
        redirect(:element         => :add_comment_form_container, 
                 :to              => :after_add, 
                 :page_id         => param(:page_id), 
                 :page_comment_id => instance.page_comment_id)
      end
    end # }}}

    def after_add
      HTML.div.message { 
        tl(:comment_is_awaiting_validation)
      }
    end

    def website_updates
      components = plugin_get(Hook.publish.website_updates)

      return unless components.length > 0

      Aurita::GUI::Page.new(:header   => tl(:website_updates), 
                            :sortable => true) { 
        components.map { |c|
          HTML.div { c }
        }
      } 
    end

    def unvalidated_comments_box
    # {{{
      box          = Box.new(:class => :topic_inline, 
                             :id    => :unvalidated_comments_box)
      box.header   = tl(:unvalidated_comments)
      comment_list = unvalidated_comments_box_body
      
      return unless comment_list

      box.body     = comment_list
      box
    end # }}}

    def unvalidated_comments_box_body
    # {{{
      comments = Page_Comment.select { |p|
        p.where(:validated => false)
        p.order_by(:timestamp_created, :desc)
      }.to_a

      return unless comments.length > 0

      HTML.ul.unvalidated_comment_list { 
        comments.map { |c|
          call_delete   = link_to(:controller => 'Publish::Page_Comment', 
                                  :action     => :perform_delete, 
                                  :element    => :dispatcher, 
                                  :id         => c.page_comment_id)
          call_validate = link_to(:controller => 'Publish::Page_Comment', 
                                  :action     => :perform_validate, 
                                  :element    => :dispatcher, 
                                  :id         => c.page_comment_id)
          page = c.page
          HTML.li { 
            HTML.div.unvalidated_comment_tools { 
              Text_Button.new(:icon    => 'delete.gif', 
                              :onclick => call_delete) +
              Text_Button.new(:icon    => 'ok.gif', 
                              :onclick => call_validate) 
            } + 
            HTML.div.unvalidated_comment_page { 
              tl(:page) + ': ' + link_to(page) { page.title }
            } +
            HTML.div.unvalidated_comment_text { 
              "#{c.author_email}: #{c.comment}"
            }
          }
        }
      }
    end # }}}

    def perform_delete
      super()
      redirect(:element => :unvalidated_comments_box_body, 
               :to      => :unvalidated_comments_box_body)
    end

    def perform_validate
      c = Page_Comment.get(id())
      return unless c
      c[:validated] = true
      c.commit

      redirect(:element => :unvalidated_comments_box_body, 
               :to      => :unvalidated_comments_box_body)
    end

  end

end
end
end

