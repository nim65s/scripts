def generator():
    yield from range(5)

async def coroutine():
    return await async_read()

async def async_generator():
    yield ...

[... async for item in async_gen()]
[await func() for func in coroutines()]
