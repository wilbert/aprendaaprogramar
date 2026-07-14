# frozen_string_literal: true

# The tutorial engine (lib/learn_to_program_tutorial) is a self-contained body of
# legacy Ruby that predates Zeitwerk naming conventions. Load it explicitly here so
# that `LearnToProgramTutorial` and its top-level constants are available to the
# controller, without letting Zeitwerk try to autoload it.
require Rails.root.join("lib", "learn_to_program_tutorial").to_s
