# django-pylibmc-bug

Django CacheMiddleware has a multi-threading issue with pylibmc.

CacheMiddleware shares a thread-unsafe cache object with many threads. It works
in most cache backends have Python implementations, but pylibmc is C
with Python bindings.

# How to reproduce

This is a simple Django project, with only django and pylibmc installed. Just
start it `./manage.py runserver` with a localhost memcached and run lots of
concurrent requests: `ab -n100 -c10 http://localhost:8000/`

This will trigger some exceptions like:

```
Traceback (most recent call last):
  File "pylibmcbug/lib/python3.9/site-packages/django/core/handlers/exception.py", line 47, in inner
    response = get_response(request)
  File "pylibmcbug/lib/python3.9/site-packages/django/core/handlers/base.py", line 181, in _get_response
    response = wrapped_callback(request, *callback_args, **callback_kwargs)
  File "pylibmcbug/lib/python3.9/site-packages/django/utils/decorators.py", line 122, in _wrapped_view
    result = middleware.process_request(request)
  File "pylibmcbug/lib/python3.9/site-packages/django/middleware/cache.py", line 145, in process_request
    cache_key = get_cache_key(request, self.key_prefix, 'GET', cache=self.cache)
  File "pylibmcbug/lib/python3.9/site-packages/django/utils/cache.py", line 362, in get_cache_key
    headerlist = cache.get(cache_key)
  File "pylibmcbug/lib/python3.9/site-packages/django/core/cache/backends/memcached.py", line 77, in get
    return self._cache.get(key, default)
pylibmc.ConnectionError: error 3 from memcached_get(:1:views.decorators.cache.cache_): (0x7f290400bd60) FAILURE, poll() returned a value that was not dealt with,  host: localhost:11211 -> libmemcached/io.cc:254
```
