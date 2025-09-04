// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// import AnalysisStatusController from "controllers/analysis_status_controller"
// application.register("analysis-status", AnalysisStatusController)

// import PasswordVisibilityController from "controllers/password_visibility_controller"
// application.register("password-visibility", PasswordVisibilityController)

// import ToastController from "controllers/toast_controller"
// application.register("toast", ToastController)

// import ModalController from "controllers/modal_controller"
// application.register("modal", ModalController)

// import FadeController from "controllers/fade_controller"
// application.register("fade", FadeController)