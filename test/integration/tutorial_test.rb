# frozen_string_literal: true

require "test_helper"

class TutorialTest < ActionDispatch::IntegrationTest
  test "root renders the tutorial table of contents" do
    get "/"
    assert_response :success
    assert_equal "text/html", @response.media_type
    assert_includes @response.body, "Aprenda a Programar"
    assert_includes @response.body, "o tutorial original"
  end

  test "legacy index.rb path renders a chapter" do
    get "/index.rb", params: { "Chapter" => "01" }
    assert_response :success
    assert_includes @response.body, "Números"
  end

  test "each tutorial chapter renders without an engine error" do
    %w[00 01 02 03 04 05 06 07 08 09 10 11].each do |chapter|
      get "/index.rb", params: { "Chapter" => chapter }
      assert_response :success, "chapter #{chapter} should render"
      refute_includes @response.body, "ERRO: envie um e-mail",
                      "chapter #{chapter} raised inside the tutorial engine"
    end
  end

  test "ShowTutorialCode returns the engine source as plain text" do
    get "/index.rb", params: { "ShowTutorialCode" => "1" }
    assert_response :success
    assert_equal "text/plain", @response.media_type
    assert_includes @response.body, "module LearnToProgram"
  end

  test "health check endpoint is up" do
    get "/up"
    assert_response :success
  end
end
