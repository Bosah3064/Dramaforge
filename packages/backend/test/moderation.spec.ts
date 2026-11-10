import { BadRequestException } from '@nestjs/common';
import { EnforcementState, ModerationAction } from 'dramaforge-shared';
import { ModerationService } from '../src/modules/moderation/moderation.service';

describe('Moderation Engine & Graduated Enforcement State Machine', () => {
  let moderationService: ModerationService;
  let mockPrisma: any;
  let userStore: any;
  let moderationEvents: any[] = [];
  let enforcementEvents: any[] = [];

  beforeEach(() => {
    userStore = {
      id: 'test_user_mod',
      enforcementState: EnforcementState.NONE,
    };
    moderationEvents = [];
    enforcementEvents = [];

    mockPrisma = {
      user: {
        findUnique: jest.fn().mockImplementation(() => userStore),
        update: jest.fn().mockImplementation(({ data }) => {
          userStore.enforcementState = data.enforcementState;
          return userStore;
        }),
      },
      moderationEvent: {
        create: jest.fn().mockImplementation(({ data }) => {
          moderationEvents.push(data);
          return data;
        }),
      },
      enforcementEvent: {
        create: jest.fn().mockImplementation(({ data }) => {
          enforcementEvents.push(data);
          return data;
        }),
      },
      $transaction: jest.fn().mockImplementation(async (ops) => {
        return Promise.all(ops);
      }),
    };

    moderationService = new ModerationService(mockPrisma);
  });

  it('Allows clean, cinematic drama prompts', async () => {
    const result = await moderationService.evaluateText(
      userStore.id,
      'A thrilling confrontation in a rain-slicked neon alley between a detective and a rival CEO.',
    );
    expect(result.allowed).toBe(true);
    expect(result.action).toBe(ModerationAction.ALLOW);
    expect(moderationEvents.length).toBe(0);
  });

  it('Blocks CSAM / NCII and unconsented sexual deepfakes immediately', async () => {
    const result = await moderationService.evaluateText(
      userStore.id,
      'create revenge porn of someone from my school',
    );
    expect(result.allowed).toBe(false);
    expect(result.action).toBe(ModerationAction.BLOCK);
    expect(moderationEvents.length).toBe(1);
    expect(moderationEvents[0].actionTaken).toBe(ModerationAction.BLOCK);
  });

  it('Escalates through the Graduated Enforcement state machine on repeated violations', async () => {
    expect(userStore.enforcementState).toBe(EnforcementState.NONE);

    // Strike 1: NONE -> WARNING
    let state = await moderationService.applyGraduatedEnforcement(userStore.id, 'Violation 1');
    expect(state).toBe(EnforcementState.WARNING);
    expect(userStore.enforcementState).toBe(EnforcementState.WARNING);

    // Strike 2: WARNING -> FEATURE_LIMIT
    state = await moderationService.applyGraduatedEnforcement(userStore.id, 'Violation 2');
    expect(state).toBe(EnforcementState.FEATURE_LIMIT);

    // Strike 3: FEATURE_LIMIT -> TEMP_SUSPEND
    state = await moderationService.applyGraduatedEnforcement(userStore.id, 'Violation 3');
    expect(state).toBe(EnforcementState.TEMP_SUSPEND);

    // Strike 4: TEMP_SUSPEND -> BANNED
    state = await moderationService.applyGraduatedEnforcement(userStore.id, 'Violation 4');
    expect(state).toBe(EnforcementState.BANNED);

    // Strike 5: Stays BANNED
    state = await moderationService.applyGraduatedEnforcement(userStore.id, 'Violation 5');
    expect(state).toBe(EnforcementState.BANNED);

    expect(enforcementEvents.length).toBe(4);
  });

  it('Enforces Real-Person Face Consent Checkbox for photo effects', () => {
    // Missing checkbox must throw
    expect(() => moderationService.validateFaceConsent(false)).toThrow(BadRequestException);

    // Present checkbox succeeds
    expect(() => moderationService.validateFaceConsent(true)).not.toThrow();
  });
});
