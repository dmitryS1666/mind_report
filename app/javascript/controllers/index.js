// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

import AnalysisStatusController from "./analysis_status_controller"
application.register("analysis-status", AnalysisStatusController)

import PasswordVisibilityController from "./password_visibility_controller"
application.register("password-visibility", PasswordVisibilityController)

import ToastController from "./toast_controller"
application.register("toast", ToastController)

// import DrawerController from "./drawer_controller"
// application.register("drawer", DrawerController)

import ModalController from "./modal_controller"
application.register("modal", ModalController)