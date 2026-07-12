from fastapi import APIRouter
from app.api.v1.endpoints import auth, cars, vignettes, insurance, registration, maintenance, modifications, notifications, admin

api_router = APIRouter()

api_router.include_router(auth.router)
api_router.include_router(cars.router)
api_router.include_router(vignettes.router)
api_router.include_router(insurance.router)
api_router.include_router(registration.router)
api_router.include_router(maintenance.router)
api_router.include_router(modifications.router)
api_router.include_router(notifications.router)
api_router.include_router(admin.router)
