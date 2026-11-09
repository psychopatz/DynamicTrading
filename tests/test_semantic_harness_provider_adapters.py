from __future__ import annotations

import sys
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
CORE_REPOSITORY = REPOSITORY.parent / "psychopatzCore"
CORE_TOOLS = str(CORE_REPOSITORY / "tools")
if CORE_TOOLS not in sys.path:
    sys.path.insert(0, CORE_TOOLS)

from semantic_harness.provider_registry import (  # noqa: E402
    SEMANTIC_EXECUTION_SCHEMA,
    core_registry,
)
from tools.semantic_harness.provider_adapters import (  # noqa: E402
    DT_ABSTRACT_PROVIDER_ID,
    DT_COMMON_PROVIDER_ID,
    DT_HOOMANS_PROVIDER_ID,
    compose_dynamic_trading_profile,
    profile_provider_ids,
    register_dynamic_trading_profiles,
)


class DynamicTradingProviderAdapterTests(unittest.TestCase):
    def test_profile_selection_emits_core_worker_launch_metadata(self) -> None:
        selection = compose_dynamic_trading_profile(
            "dtabstract",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_ABSTRACT_PROVIDER_ID,
            ),
        )

        self.assertEqual(
            selection.launch_environment(),
            {
                "SEMANTIC_HARNESS_PROFILE": "dtabstract",
                "SEMANTIC_HARNESS_PROVIDER_IDS": (
                    "PsychopatzCore,DTCommon,DTAbstract"
                ),
                "SEMANTIC_HARNESS_MATERIALIZATION_MODE": "abstract",
            },
        )

    def test_abstract_and_physical_profiles_share_core_execution_contract(self) -> None:
        registry = register_dynamic_trading_profiles(core_registry())

        abstract = registry.resolve(
            "dtabstract",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_ABSTRACT_PROVIDER_ID,
            ),
        )
        physical = registry.resolve(
            "dthoomans",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_HOOMANS_PROVIDER_ID,
            ),
        )

        self.assertEqual(abstract.profile.materialization_mode, "abstract")
        self.assertEqual(physical.profile.materialization_mode, "physical")
        self.assertEqual(
            abstract.provider_ids,
            profile_provider_ids("dtabstract"),
        )
        self.assertEqual(
            physical.provider_ids,
            profile_provider_ids("dthoomans"),
        )

        common = registry.provider(DT_COMMON_PROVIDER_ID)
        abstract_provider = registry.provider(DT_ABSTRACT_PROVIDER_ID)
        physical_provider = registry.provider(DT_HOOMANS_PROVIDER_ID)
        self.assertIsNotNone(common)
        self.assertEqual(common.execution_schema, SEMANTIC_EXECUTION_SCHEMA)
        self.assertEqual(
            common.execution_callbacks,
            abstract_provider.execution_callbacks,
        )
        self.assertEqual(
            abstract_provider.execution_callbacks,
            physical_provider.execution_callbacks,
        )

    def test_abstract_profile_does_not_require_physical_adopter(self) -> None:
        registry = register_dynamic_trading_profiles(
            core_registry(), include_hoomans=False
        )
        resolved = registry.resolve(
            "dtabstract",
            available_provider_ids=(
                "PsychopatzCore",
                DT_COMMON_PROVIDER_ID,
                DT_ABSTRACT_PROVIDER_ID,
            ),
        )
        self.assertNotIn(DT_HOOMANS_PROVIDER_ID, resolved.provider_ids)


if __name__ == "__main__":
    unittest.main()
