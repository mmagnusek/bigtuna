module BigTuna
  class Hooks::Mailer < Hooks::Base
    NAME = "mailer"

    def build_fixed(build, config)
      recipients = config["recipients"]
      Sender.delay.build_fixed(build, recipients) unless recipients.blank?
    end

    def build_still_fails(build, config)
      recipients = config["recipients"]
      Sender.delay.build_still_fails(build, recipients) unless recipients.blank?
    end

    def build_failed(build, config)
      recipients = config["recipients"]
      Sender.delay.build_failed(build, recipients) unless recipients.blank?
    end

    class Sender < ActionMailer::Base
      self.append_view_path("lib/big_tuna/hooks")
      default :from => "no-reply@polarion.com"
      
      def link_to_build(build)
        @build_url = "http://ci.cloud.polarion.com/builds/#{build.to_param}"
      end

      def cucumber_build_output(build)
        doc = Nokogiri::HTML(open(build.output_path('cucumber')))
        output = ""
        doc.css('.step.failed').each do |step|
          output << step.parent.parent.to_s
        end
        output
      end 

      def rspec_build_output(build)
        doc = Nokogiri::HTML(open(build.output_path('rspec')))
        output = ""
        doc.css('dd.failed').each do |step|
          output << step.parent.parent.to_s
        end
        output
      end
      
      def setup_data(build)
        @build = build
        @build_url = link_to_build(build)
        @project = @build.project
        @cucumber_output = cucumber_build_output(@build)
        @rspec_output = rspec_build_output(@build)
      end

      def build_failed(build, recipients)
        setup_data(build)
        mail(:to => recipients, :subject => "Build '#{@build.display_name}' in '#{@project.name}' failed") do |format|
          format.html { render "mailer/build_failed", :layout => 'layout' }
        end     
      end

      def build_still_fails(build, recipients)
        setup_data(build)
        mail(:to => recipients, :subject => "Build '#{@build.display_name}' in '#{@project.name}' still fails") do |format|
          format.html { render "mailer/build_still_fails", :layout => 'layout' }
        end
      end
      
      def build_fixed(build, recipients)
        setup_data(build)
        mail(:to => recipients, :subject => "Build '#{@build.display_name}' in '#{@project.name}' fixed") do |format|
          format.html { render "mailer/build_fixed", :layout => 'layout' }
        end
      end
    end
  end
end
