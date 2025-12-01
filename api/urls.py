from rest_framework.routers import DefaultRouter
from django.urls import path, include
from .views import BotViewSet, ScenarioViewSet, StepViewSet

router = DefaultRouter()
router.register(r'bots', BotViewSet)
router.register(r'scenarios', ScenarioViewSet)
router.register(r'scenarios/(?P<scenario_id>\d+)/steps', StepViewSet, basename='steps')

urlpatterns = [
    path('', include(router.urls)),
]