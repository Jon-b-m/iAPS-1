public enum SetupUIResult<UserInteractionRequired, CreatedAndOnboarded> {
    case userInteractionRequired(UserInteractionRequired)
    case createdAndOnboarded(CreatedAndOnboarded)
}
