import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateEffectJobDto, EffectsService } from './effects.service';

@ApiTags('Viral Photo Effects (Hug, Kiss, Dance, etc.)')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('effects')
export class EffectsController {
  constructor(private readonly effectsService: EffectsService) {}

  @Post('jobs')
  @ApiOperation({ summary: 'Create animated photo effect (requires explicit face consent)' })
  @ApiResponse({ status: 201, description: 'Effect job completed or processing' })
  async createEffectJob(@Req() req: any, @Body() dto: CreateEffectJobDto) {
    return this.effectsService.createEffectJob(req.user.id, dto);
  }

  @Get('jobs/:id')
  @ApiOperation({ summary: 'Get photo effect status and video result' })
  async getEffectJob(@Req() req: any, @Param('id') id: string) {
    return this.effectsService.getEffectJob(req.user.id, id);
  }
}
