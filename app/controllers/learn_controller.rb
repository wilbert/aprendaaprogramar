# frozen_string_literal: true

# Serves the "Learn to Program" tutorial (Chris Pine, PT-BR translation).
#
# The actual page generation lives in the legacy engine at
# lib/learn_to_program_tutorial. That engine was written against Ruby's CGI class:
# it reads request parameters from `cgi.params` (a Hash of String => Array) and
# writes its finished HTML back through `cgi.out { body }`. This controller provides
# a tiny CGI-compatible shim so the engine runs unchanged under Rails 8.
class LearnController < ApplicationController
  # The engine executes the tutorial's sample code by temporarily swapping out
  # Kernel#puts/#gets/#putc — process-global state that is not reentrant. Serialize
  # rendering within a process so concurrent Puma threads can't corrupt it. (Multiple
  # Puma worker processes still render in parallel; each has its own Kernel.)
  RENDER_MUTEX = Mutex.new

  SUPPORTED_LOCALES = %w[pt en].freeze

  # Minimal stand-in for Ruby's CGI object, exposing just what the engine uses.
  class CgiShim
    attr_reader :params, :response_content_type, :locale

    # +params+ is a Hash of String => Array (CGI semantics). Missing keys return
    # [nil] so the engine's `params['X'][0]` never raises. +locale+ tells the
    # engine which language to render the chrome/labels in.
    def initialize(params, locale = "pt")
      @params = Hash.new { |_hash, _key| [nil] }
      @params.merge!(params)
      @locale = locale
      @response_content_type = "text/html"
    end

    # The engine calls `cgi.out('text/plain') { body }` or `cgi.out { body }`.
    # Record the requested content type and return the body to the controller.
    def out(content_type = "text/html")
      @response_content_type = content_type
      block_given? ? yield : nil
    end
  end

  def index
    shim = CgiShim.new(cgi_params, current_locale)
    body = RENDER_MUTEX.synchronize { LearnToProgramTutorial.handle_request(shim) }

    if shim.response_content_type == "text/plain"
      render plain: body
    else
      render html: body.to_s.html_safe, layout: false # rubocop:disable Rails/OutputSafety
    end
  end

  private

  # Locale comes from the route (/pt or /en); default to Portuguese.
  def current_locale
    loc = params[:locale].to_s
    SUPPORTED_LOCALES.include?(loc) ? loc : "pt"
  end

  # Translate Rails query parameters into CGI-style params: every value wrapped
  # in an Array, e.g. { "Chapter" => ["00"] }.
  def cgi_params
    request.query_parameters.transform_values { |value| Array(value) }
  end
end
