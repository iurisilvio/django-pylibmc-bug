from datetime import datetime

from django.http import JsonResponse
from django.views.decorators.cache import cache_page


@cache_page(timeout=60)
def cached_page(request):
    return JsonResponse({
        'dt': datetime.now(),
    })
