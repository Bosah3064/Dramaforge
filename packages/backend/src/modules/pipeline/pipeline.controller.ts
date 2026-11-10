import { Body, Controller, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GenerateStoryDto, PipelineService, QuickGenerateDto } from './pipeline.service';

@ApiTags('Drama Generation Pipeline (4-Stage & Quick)')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('pipeline')
export class PipelineController {
  constructor(private readonly pipelineService: PipelineService) {}

  @Post('quick-generate')
  @ApiOperation({ summary: 'Flow A: Quick Generation (One-tap end-to-end short drama)' })
  @ApiResponse({ status: 201, description: 'Fully assembled drama video' })
  async quickGenerate(@Req() req: any, @Body() dto: QuickGenerateDto) {
    return this.pipelineService.runQuickGeneration(req.user.id, dto);
  }

  @Post('story')
  @ApiOperation({ summary: 'Stage 1: Generate Story & Script (Free)' })
  async generateStory(@Req() req: any, @Body() dto: GenerateStoryDto) {
    return this.pipelineService.generateStory(req.user.id, dto);
  }

  @Post('storyboard/:storyId')
  @ApiOperation({ summary: 'Stage 2: Generate Storyboard & Keyframe Thumbnails (2 coins/shot)' })
  async generateStoryboard(@Req() req: any, @Param('storyId') storyId: string) {
    return this.pipelineService.generateStoryboard(req.user.id, storyId);
  }

  @Post('shots/:storyId')
  @ApiOperation({ summary: 'Stage 3: Generate Video Clips for all shots (8 coins/shot)' })
  async generateShotVideos(@Req() req: any, @Param('storyId') storyId: string) {
    return this.pipelineService.generateShotVideos(req.user.id, storyId);
  }

  @Post('shots/regenerate/:shotId')
  @ApiOperation({ summary: 'Stage 3b: Granular regeneration of a single shot (8 coins)' })
  async regenerateSingleShot(@Req() req: any, @Param('shotId') shotId: string) {
    return this.pipelineService.regenerateSingleShot(req.user.id, shotId);
  }

  @Post('final-cut/:projectId')
  @ApiOperation({ summary: 'Stage 4: Assemble Final Cut with Subtitles & Audio (15 coins for 1080p / 0 for subscribers)' })
  async assembleFinalCut(
    @Req() req: any,
    @Param('projectId') projectId: string,
    @Body('removeWatermark') removeWatermark?: boolean,
  ) {
    return this.pipelineService.assembleFinalCut(req.user.id, projectId, removeWatermark);
  }
}
