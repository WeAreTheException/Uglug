extends Resource
class_name CardFeedbackDatabase

@export var feedbacks: Array[CardFeedbackData]


func get_feedback(feedback_key: String) -> CardFeedbackData:
	for feedback in feedbacks:
		if feedback == null:
			continue

		if feedback.feedback_key == feedback_key:
			return feedback

	return null
