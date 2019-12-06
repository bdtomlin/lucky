require "../spec_helper"

include ContextHelper

describe Lucky::TextResponse do
  describe "#print" do
    it "uses the default status if none is set" do
      context = build_context
      print_response(context, status: nil)
      context.response.status_code.should eq Lucky::TextResponse::DEFAULT_STATUS
    end

    it "uses the passed in status" do
      context = build_context
      print_response(context, status: 300)
      context.response.status_code.should eq 300
    end

    it "uses the response status if it's set, and Lucky::TextResponse status is nil" do
      context = build_context
      context.response.status_code = 300
      print_response(context, status: nil)
      context.response.status_code.should eq 300
    end

    it "prints no body with a head call" do
      context = build_context("HEAD")
      print_response_with_body(context, "Body", status: nil)
      context.request.method.should eq "HEAD"
      context.request.body.to_s.should eq ""
      context.response.status_code.should eq 200
    end

    it "gzips if enabled" do
      Lucky::TextResponse.temp_config(gzip_enabled: true) do
        output = IO::Memory.new
        context = build_context_with_io(output)
        context.request.headers["Accept-Encoding"] = "gzip"

        print_response(context, status: 200, body: "some body")
        context.response.close

        context.response.headers["Content-Encoding"].should eq "gzip"
        output.to_s.ends_with?("some body").should be_false
      end
    end
  end
end

private def print_response(context : HTTP::Server::Context, status : Int32?, body = "")
  print_response_with_body(context, body, status)
end

private def print_response_with_body(context : HTTP::Server::Context, body : String, status : Int32?)
  Lucky::TextResponse.new(context, "text/html", body, status: status).print
end
