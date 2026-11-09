"""Dynamic Trading's thin provider adapters for the Core semantic harness.

The executable harness remains owned by PsychopatzCore.  This package only
describes Dynamic Trading's optional provider/profile composition so Core can
validate it without importing merchant policy or a second worker engine.
"""

from .provider_adapters import (
    DT_ABSTRACT_PROVIDER_ID,
    DT_COMMON_PROVIDER_ID,
    DT_HOOMANS_PROVIDER_ID,
    register_dynamic_trading_profiles,
)

__all__ = [
    "DT_ABSTRACT_PROVIDER_ID",
    "DT_COMMON_PROVIDER_ID",
    "DT_HOOMANS_PROVIDER_ID",
    "register_dynamic_trading_profiles",
]
