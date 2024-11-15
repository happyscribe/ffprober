# typed: false
# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
require 'test_helper'
require 'uri'

class FfproberTest < Minitest::Test
  # rubocop:disable Minitest/MultipleAssertions
  def test_json_input
    ffprobe = Ffprober::Parser.from_json(
      File.read('test/assets/sample video.json')
    )

    assert_equal 'test/assets/sample video.m4v', ffprobe.format.filename

    assert_equal '44100', ffprobe.audio_streams.first.sample_rate
    assert_equal 1, ffprobe.audio_streams.count

    assert_equal 1, ffprobe.subtitle_streams.count
    assert_equal 'eng', ffprobe.subtitle_streams.first.tags[:language]

    assert_equal 1, ffprobe.video_streams.count
    assert_equal 480, ffprobe.video_streams.first.width

    assert_equal 3, ffprobe.chapters.count
    assert_equal '1/1000', ffprobe.chapters.first.time_base

    assert_equal 3, ffprobe.json[:streams].count # json raw access
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  def test_file_input
    skip unless Ffprober::FfprobeVersion.valid?

    ffprobe = Ffprober::Parser.from_file(
      'test/assets/301 extracting a ruby gem.m4v'
    )

    assert_equal(
      'test/assets/301 extracting a ruby gem.m4v',
      ffprobe.format.filename
    )

    assert_equal '44100', ffprobe.audio_streams.first.sample_rate
    assert_equal 1, ffprobe.audio_streams.count

    assert_equal 0, ffprobe.subtitle_streams.count

    assert_equal 1, ffprobe.video_streams.count
    assert_equal 480, ffprobe.video_streams.first.width

    assert_equal 0, ffprobe.chapters.count

    assert_equal 2, ffprobe.json[:streams].count # json raw access
  end
  # rubocop:enable Minitest/MultipleAssertions

  # rubocop:disable Minitest/MultipleAssertions
  def test_url_input
    skip unless Ffprober::FfprobeVersion.valid?

    path = File.join(assets_path, '301 extracting a ruby gem.m4v')
    url = "file://#{path}"

    ffprobe = Ffprober::Parser.from_url(url)

    assert_equal(url, ffprobe.format.filename)

    assert_equal '44100', ffprobe.audio_streams.first.sample_rate
    assert_equal 1, ffprobe.audio_streams.count

    assert_equal 0, ffprobe.subtitle_streams.count

    assert_equal 1, ffprobe.video_streams.count
    assert_equal 480, ffprobe.video_streams.first.width

    assert_equal 0, ffprobe.chapters.count

    assert_equal 2, ffprobe.json[:streams].count # json raw access
  end
  # rubocop:enable Minitest/MultipleAssertions

  def test_error_response
    skip unless Ffprober::FfprobeVersion.valid?

    err = assert_raises Ffprober::FfprobeError do
      Ffprober::Parser.from_url('http://localhost/notarealfile.mp4')
    end
    assert_equal('Ffprobe responded with: ' \
                 'Connection refused (-61)', err.message)
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
