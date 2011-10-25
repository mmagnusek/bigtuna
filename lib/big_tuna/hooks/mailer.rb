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
      default :from => "info@ci.appelier.com"
      
      def link_to_build(build)
        @build_url = "http://ci.cloud.polarion.com/builds/#{build.to_param}"
      end

      def build_failed(build, recipients)
        @build = build
        @project = @build.project
        mail(:to => recipients, :subject => "Build '#{@build.display_name}' in '#{@project.name}' failed") do |format|
          format.text { render "mailer/build_failed" }
        end
      end

      def build_still_fails(build, recipients)
        @build = build
        @build_url = link_to_build(build)
        @project = @build.project
        # @cucumber = File.read(build.output_path('cucumber'))
        # @rspec = File.read(build.output_path('rspec'))
        mail(:to => recipients, :subject => "Build '#{@build.display_name}' in '#{@project.name}' still fails") do |format|
          format.text { render "mailer/build_still_fails" }
        end
      end

      def build_fixed(build, recipients)
        @build = build
        @project = @build.project
        mail(:to => recipients, :subject => "Build '#{@build.display_name}' in '#{@project.name}' fixed") do |format|
          format.text { render "mailer/build_fixed" }
        end
      end
    end
  end
end
