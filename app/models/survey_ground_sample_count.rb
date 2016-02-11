class SurveyGroundSampleCount < ActiveRecord::Base
  has_paper_trail

  include Count

  # All normal attributes of Count models are mass-assignable
  attr_protected :created_at, :updated_at

  belongs_to :population_submission

  has_many :survey_ground_sample_count_strata, dependent: :destroy

  validates_with StratumLevelValidator
end
