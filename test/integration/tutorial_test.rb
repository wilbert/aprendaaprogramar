# frozen_string_literal: true

require "test_helper"

class TutorialTest < ActionDispatch::IntegrationTest
  test "root redirects to the Portuguese version" do
    get "/"
    assert_redirected_to "/pt"
  end

  test "legacy index.rb redirects to /pt preserving the chapter" do
    get "/index.rb", params: { "Chapter" => "01" }
    assert_redirected_to "/pt/index.rb?Chapter=01"
  end

  test "/pt renders the Portuguese table of contents" do
    get "/pt"
    assert_response :success
    assert_equal "text/html", @response.media_type
    assert_includes @response.body, "Aprenda a Programar"
    assert_includes @response.body, "o tutorial original"
    refute_includes @response.body, "translation in progress"
  end

  test "/en renders English chrome with the translation banner" do
    get "/en"
    assert_response :success
    assert_includes @response.body, "the original tutorial"          # English menu heading
    assert_includes @response.body, "still being translated into English"  # em tradução banner
    assert_includes @response.body, "ri-lang"                        # language switcher
  end

  test "/en chapter shows the English label, in-locale nav, and a switch-to-PT link" do
    get "/en/index.rb", params: { "Chapter" => "01" }
    assert_response :success
    assert_includes @response.body, "Numbers"                          # English chapter label
    assert_includes @response.body, "/en/index.rb?Chapter="            # chapter nav stays in /en
    # the language switcher points to the SAME chapter in the other locale
    assert_includes @response.body, '<a href="/pt/index.rb?Chapter=01">PT</a>'
  end

  test "each chapter renders in both locales without an engine error" do
    %w[pt en].each do |loc|
      %w[00 01 02 03 04 05 06 07 08 09 10 11].each do |chapter|
        get "/#{loc}/index.rb", params: { "Chapter" => chapter }
        assert_response :success, "#{loc} chapter #{chapter} should render"
        refute_includes @response.body, "ERRO: envie um e-mail",
                        "#{loc} chapter #{chapter} raised inside the tutorial engine"
      end
    end
  end

  test "ShowTutorialCode returns the engine source as plain text" do
    get "/pt/index.rb", params: { "ShowTutorialCode" => "1" }
    assert_response :success
    assert_equal "text/plain", @response.media_type
    assert_includes @response.body, "module LearnToProgram"
  end

  test "health check endpoint is up" do
    get "/up"
    assert_response :success
  end
end
