"""Dynamic Trading provider descriptors for PsychopatzCore's harness.

This module is deliberately declarative.  It does not start a worker, import
Project Hoomans, or move merchant state into Core.  DTCommon remains the
owner of trading policy; DTAbstract and DTHoomans only select the abstract or
physical representation capability for the same Core execution contract.
"""

from __future__ import annotations

from semantic_harness.provider_registry import (
    CORE_PROVIDER_ID,
    SEMANTIC_EXECUTION_CALLBACKS,
    ProviderDescriptor,
    ProviderRegistry,
    ProfileDescriptor,
)
from semantic_harness.profile_loader import ProfileSelection, compose_profile


DT_COMMON_PROVIDER_ID = "DTCommon"
DT_ABSTRACT_PROVIDER_ID = "DTAbstract"
DT_HOOMANS_PROVIDER_ID = "DTHoomans"

_TRADING_EXECUTION_CALLBACKS = tuple(
    callback
    for callback in SEMANTIC_EXECUTION_CALLBACKS
    if callback != "interaction"
)
_TRADING_CAPABILITIES = (
    "semantic.conversation",
    "semantic.identity",
    "semantic.interaction",
    "trading.conversation",
    "trading.interaction",
)


def provider_descriptors(
    *, include_abstract: bool = True, include_hoomans: bool = True
) -> tuple[ProviderDescriptor, ...]:
    """Return the optional DT descriptors without importing an adopter.

    DTHoomans intentionally depends on the shared DTCommon contract rather
    than naming Project Hoomans as a harness dependency.  Repository layout
    discovery is the authority that decides whether DTHoomans is available;
    this keeps the descriptor usable in a Core-only or DTAbstract composition.
    """

    descriptors = [
        ProviderDescriptor(
            provider_id=DT_COMMON_PROVIDER_ID,
            display_name="Dynamic Trading shared provider",
            repository_kind="dynamic_trading",
            requires=(CORE_PROVIDER_ID,),
            capabilities=_TRADING_CAPABILITIES,
            materialization_modes=("abstract", "physical"),
            execution_callbacks=_TRADING_EXECUTION_CALLBACKS,
        ),
    ]
    if include_abstract:
        descriptors.append(
            ProviderDescriptor(
                provider_id=DT_ABSTRACT_PROVIDER_ID,
                display_name="Dynamic Trading abstract provider",
                repository_kind="dynamic_trading",
                requires=(CORE_PROVIDER_ID, DT_COMMON_PROVIDER_ID),
                capabilities=_TRADING_CAPABILITIES + ("trading.remote",),
                materialization_modes=("abstract",),
                execution_callbacks=_TRADING_EXECUTION_CALLBACKS,
            )
        )
    if include_hoomans:
        descriptors.append(
            ProviderDescriptor(
                provider_id=DT_HOOMANS_PROVIDER_ID,
                display_name="Dynamic Trading Hoomans provider",
                repository_kind="dynamic_trading",
                requires=(CORE_PROVIDER_ID, DT_COMMON_PROVIDER_ID),
                capabilities=_TRADING_CAPABILITIES + ("trading.physical",),
                materialization_modes=("physical",),
                execution_callbacks=_TRADING_EXECUTION_CALLBACKS,
            )
        )
    return tuple(descriptors)


def register_dynamic_trading_profiles(
    registry: ProviderRegistry,
    *,
    include_abstract: bool = True,
    include_hoomans: bool = True,
) -> ProviderRegistry:
    """Register DTCommon plus the explicitly requested provider profiles."""

    descriptors = provider_descriptors(
        include_abstract=include_abstract,
        include_hoomans=include_hoomans,
    )
    for descriptor in descriptors:
        registry.register_provider(descriptor)

    if include_abstract:
        registry.register_profile(
            ProfileDescriptor(
                profile_id="dtabstract",
                display_name="Dynamic Trading abstract",
                provider_ids=(
                    CORE_PROVIDER_ID,
                    DT_COMMON_PROVIDER_ID,
                    DT_ABSTRACT_PROVIDER_ID,
                ),
                materialization_mode="abstract",
            )
        )
    if include_hoomans:
        registry.register_profile(
            ProfileDescriptor(
                profile_id="dthoomans",
                display_name="Dynamic Trading Hoomans",
                provider_ids=(
                    CORE_PROVIDER_ID,
                    DT_COMMON_PROVIDER_ID,
                    DT_HOOMANS_PROVIDER_ID,
                ),
                materialization_mode="physical",
            )
        )
    return registry


def compose_dynamic_trading_profile(
    profile_id: str,
    *,
    available_provider_ids: tuple[str, ...] | None = None,
) -> ProfileSelection:
    """Resolve one DT profile through Core's generic profile loader."""

    return compose_profile(
        profile_id,
        registrars=(register_dynamic_trading_profiles,),
        available_provider_ids=available_provider_ids,
    )


def profile_provider_ids(profile_id: str) -> tuple[str, ...]:
    """Expose the stable composition without constructing a registry."""

    compositions: dict[str, tuple[str, ...]] = {
        "dtabstract": (
            CORE_PROVIDER_ID,
            DT_COMMON_PROVIDER_ID,
            DT_ABSTRACT_PROVIDER_ID,
        ),
        "dthoomans": (
            CORE_PROVIDER_ID,
            DT_COMMON_PROVIDER_ID,
            DT_HOOMANS_PROVIDER_ID,
        ),
    }
    try:
        return compositions[str(profile_id)]
    except KeyError as error:
        raise ValueError(f"unknown Dynamic Trading profile: {profile_id}") from error


__all__ = [
    "DT_ABSTRACT_PROVIDER_ID",
    "DT_COMMON_PROVIDER_ID",
    "DT_HOOMANS_PROVIDER_ID",
    "profile_provider_ids",
    "compose_dynamic_trading_profile",
    "provider_descriptors",
    "register_dynamic_trading_profiles",
]
