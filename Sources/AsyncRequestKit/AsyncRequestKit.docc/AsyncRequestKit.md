# ``AsyncRequestKit``

A Swift Concurrency networking toolkit for explicit retry, timeout, request
coordination, controlled parallelism, and token refresh.

## Overview

Use ``HTTPClient`` when an application needs an isolated client and ``AK`` when
a shared facade is appropriate. Compose ``RetryPolicy`` and
``TokenRefreshCoordinator`` instead of hiding retry or authentication work.

## Topics

### Requests

- ``HTTPClient``
- ``AK``
- ``HTTPResponse``

### Reliability

- ``RetryPolicy``
- ``TokenRefreshCoordinator``
- ``withTimeout(_:operation:)``

### Coordination

- ``AsyncQueue``
- ``AsyncCache``
- ``withLimitedConcurrency(maxConcurrentTasks:items:operation:)``
